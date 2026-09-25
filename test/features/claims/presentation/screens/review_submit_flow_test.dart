import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/data/datasources/claims_remote_data_source.dart';
import 'package:insurflow/features/claims/data/repositories/claims_repository_impl.dart';
import 'package:insurflow/features/claims/domain/usecases/submit_claim.dart';

/// Serves a claim whose sections can change between reads, the way the
/// backend does once an edit screen has written to it.
class _ClaimAdapter implements HttpClientAdapter {
  _ClaimAdapter(this.requests, this.bodyFor);

  final List<RequestOptions> requests;
  final String Function(int readCount) bodyFor;
  var reads = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'GET') reads++;
    return ResponseBody.fromString(
      bodyFor(reads),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

String claimBody({required bool withSignature}) {
  final signature = withSignature
      ? '{"url":"https://res.cloudinary.com/x/signature.png",'
            '"capturedAt":"2026-09-25T09:00:00.000Z"}'
      : 'null';
  return '''
{"success":true,"data":{
  "id":"6ab613919e39977215cc33c0",
  "claimNumber":"CLM-DEMO-INS-0051",
  "status":"IN_PROGRESS",
  "vehicle":{"plateNumber":"ABC-1234","make":"Toyota","model":"Camry",
             "year":2022,"color":"White"},
  "customer":{"name":"John Doe","phone":"+1234567890"},
  "policy":{"policyNumber":"POL-1000","status":"ACTIVE"},
  "accident":{"accidentType":"OTHER","accidentDate":"2026-09-22",
              "accidentTime":"09:09","description":"Rear gate impact",
              "damageDescription":"Dented rear gate"},
  "location":{"latitude":32.2601972,"longitude":35.1288474,
              "address":"Saffarin - Beit Lid",
              "capturedAt":"2026-09-25T09:05:09.222Z"},
  "evidence":[{"imageType":"VEHICLE_FRONT",
               "url":"https://res.cloudinary.com/x/front.png",
               "uploadedAt":"2026-09-25T09:06:00.000Z"}],
  "signature":$signature
}}''';
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }

  group('review reads the claim back from the backend', () {
    test('a second read picks up a section saved in between', () async {
      // Regression: the review used to keep the snapshot it loaded on
      // entry, so a step saved from an edit screen still showed as
      // missing when the adjuster came back.
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _ClaimAdapter(
          requests,
          // First read: no signature. Second read: the signature the
          // edit screen uploaded in between.
          (reads) => claimBody(withSignature: reads > 1),
        );
      final source = ClaimsRemoteDataSourceImpl(dio);

      final before = await source.getClaimDetails('6ab613919e39977215cc33c0');
      final after = await source.getClaimDetails('6ab613919e39977215cc33c0');

      expect(before.signature?.hasImage ?? false, isFalse);
      expect(after.signature?.hasImage, isTrue);
      expect(requests.every((r) => r.method == 'GET'), isTrue);
    });
  });

  group('submit', () {
    test('sends no body, matching the endpoint contract', () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _ClaimAdapter(
          requests,
          (_) => claimBody(withSignature: true),
        );

      await ClaimsRemoteDataSourceImpl(dio).submitClaim(
        '6ab613919e39977215cc33c0',
      );

      final submit = requests.first;
      expect(submit.method, 'POST');
      expect(submit.path, '/claims/6ab613919e39977215cc33c0/inspection/submit');
      // The backend derives everything from stored claim state; it
      // takes no fields of its own.
      expect(submit.data, isNull);

      // The submit response carries only {status}, so the claim is
      // re-read for the full record.
      expect(requests[1].method, 'GET');
      expect(requests[1].path, '/claims/6ab613919e39977215cc33c0');
    });

    test('an incomplete claim surfaces the backend reason', () async {
      final failing = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _IncompleteAdapter();

      final result = await SubmitClaimUseCase(
        ClaimsRepositoryImpl(ClaimsRemoteDataSourceImpl(failing)),
      )('6ab511c8a2868d20eb37b1a9');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('submit is never sent twice', () {
    setUp(() {
      AppDependencies.reset();
      AppDependencies.init(
        tokenStore: InMemoryTokenStore(),
        preferencesStore: InMemoryAppPreferencesStore(),
      );
    });

    tearDown(AppDependencies.reset);

    testWidgets('a second confirmation does not resend the request', (
      tester,
    ) async {
      // The confirmation sheet and the request are both awaited while
      // the button stays on screen, so without the in-flight guard a
      // double tap would submit the same claim twice.
      final adapter = _HeldSubmitAdapter();
      AppDependencies.instance.dio.httpClientAdapter = adapter;

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(
          const ClaimValidationScreen(
            args: ClaimValidationArgs(
              claimId: '6ab613919e39977215cc33c0',
              claimNumber: 'CLM-DEMO-INS-0051',
            ),
            validationDuration: Duration.zero,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('validation-continue')));
      // The screen runs a looping check animation, so pumpAndSettle
      // would never return: advance by hand instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Submit Claim?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-submit-claim')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(adapter.submitCount, 1);

      // The request is still in flight; the button must refuse a
      // second run rather than opening the sheet again.
      await tester.tap(
        find.byKey(const Key('validation-continue')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.text('Submit Claim?'), findsNothing);
      expect(adapter.submitCount, 1);

      adapter.release();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(adapter.submitCount, 1);
    });
  });
}

/// Holds the submit response open so the request can be observed while
/// it is still in flight.
class _HeldSubmitAdapter implements HttpClientAdapter {
  final _gate = Completer<void>();
  var submitCount = 0;

  void release() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/inspection/submit')) {
      submitCount++;
      await _gate.future;
    }
    return ResponseBody.fromString(
      claimBody(withSignature: true),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _IncompleteAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"success":false,"message":"Inspection incomplete. Missing: signature",'
      '"errors":[{"code":"INSPECTION_INCOMPLETE",'
      '"details":"Inspection incomplete. Missing: signature"}]}',
      400,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Mirrors the guard the validation screen uses: one in-flight submit,
/// and the button disabled while it runs.
class _SubmitProbe extends StatefulWidget {
  const _SubmitProbe({required this.onSubmit});

  final Future<Either<Failure, Claim>> Function() onSubmit;

  @override
  State<_SubmitProbe> createState() => _SubmitProbeState();
}

class _SubmitProbeState extends State<_SubmitProbe> {
  var _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final result = await widget.onSubmit();
    if (!mounted) return;
    result.fold((_) => setState(() => _isSubmitting = false), (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('probe-submit'),
          onPressed: _isSubmitting ? null : _submit,
          child: const Text('Submit'),
        ),
      ),
    );
  }
}
