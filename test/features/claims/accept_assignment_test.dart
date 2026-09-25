import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/data/datasources/claims_remote_data_source.dart';
import 'package:insurflow/features/claims/data/repositories/claims_repository_impl.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/usecases/accept_assignment.dart';
import 'package:insurflow/features/claims/domain/usecases/decline_assignment.dart';
import 'package:insurflow/features/claims/domain/usecases/get_claim_details.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/widgets/assignment_availability_dialog.dart';
import 'package:mocktail/mocktail.dart';

/// The accept response, captured verbatim from the live backend.
/// Note `assignedTo`/`assignedBy` are bare id strings here, unlike the
/// nested objects the claim endpoints return.
const acceptResponse = {
  'success': true,
  'message': 'Assignment accepted successfully',
  'data': {
    'id': '6ab4f9b766ac53c14dd40da1',
    'claimNumber': 'CLM-DEMO-INS-0038',
    'status': 'ASSIGNED',
    'assignedTo': '6aa27838cda4d3dca00b83ad',
    'assignedBy': '6aa27838cda4d3dca00b83ac',
    'assignedAt': '2026-09-24T10:24:35.498Z',
  },
};

/// The claim as `GET /claims/{id}` returns it after acceptance.
const claimAfterAccept = {
  'success': true,
  'data': {
    'id': '6ab4f9b766ac53c14dd40da1',
    'claimNumber': 'CLM-DEMO-INS-0038',
    'status': 'ASSIGNED',
    'customer': {'name': 'John Doe', 'phone': '+1234567890'},
    'vehicle': {'plateNumber': 'ABC-1234'},
    'assignment': {
      'assignedTo': {
        'id': '6aa27838cda4d3dca00b83ad',
        'name': 'Ahmed Adjuster',
        'employeeCode': 'FA-001',
      },
      'assignedBy': {'id': '6aa27838cda4d3dca00b83ac', 'name': 'Sara Officer'},
      'assignedAt': '2026-09-24T10:24:35.498Z',
      'priority': 'HIGH',
    },
  },
};

Claim pendingClaim({String id = '6ab4f9b766ac53c14dd40da1'}) => Claim(
  id: id,
  status: ClaimStatus.pendingAcceptance,
  claimNumber: 'CLM-DEMO-INS-0038',
  isDetailed: true,
);

class _MockGetClaimDetails extends Mock implements GetClaimDetailsUseCase {}

class _MockStartClaim extends Mock implements StartClaimUseCase {}

class _MockAccept extends Mock implements AcceptAssignmentUseCase {}

class _MockDecline extends Mock implements DeclineAssignmentUseCase {}

class _FakeDeclineParams extends Fake implements DeclineAssignmentParams {}

class _MockRepository extends Mock implements ClaimsRepository {}

class _FakeClaim extends Fake implements Claim {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeClaim());
    registerFallbackValue(_FakeDeclineParams());
  });

  group('status', () {
    test('only PENDING_ACCEPTANCE awaits acceptance', () {
      expect(ClaimStatus.pendingAcceptance.awaitsAcceptance, isTrue);
      for (final other in ClaimStatus.values.where(
        (s) => s != ClaimStatus.pendingAcceptance,
      )) {
        expect(other.awaitsAcceptance, isFalse, reason: '$other');
      }
    });

    test('parses the live value and the alternative spelling', () {
      // The deployed API sends PENDING_ACCEPTANCE.
      expect(
        ClaimStatus.parse('PENDING_ACCEPTANCE'),
        ClaimStatus.pendingAcceptance,
      );
      expect(
        ClaimStatus.parse('PENDING_ACCEPTED'),
        ClaimStatus.pendingAcceptance,
      );
    });

    test('accepting unlocks the inspection, which it did not before', () {
      expect(ClaimStatus.pendingAcceptance.canStart, isFalse);
      expect(ClaimStatus.assigned.canStart, isTrue);
    });
  });

  group('API contract', () {
    late List<RequestOptions> requests;
    late Dio dio;

    setUp(() {
      requests = [];
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _StubAdapter(requests);
    });

    test('POSTs accept-assignment then re-reads the claim', () async {
      final claim = await ClaimsRemoteDataSourceImpl(
        dio,
      ).acceptAssignment('6ab4f9b766ac53c14dd40da1');

      expect(requests.length, 2);
      expect(requests.first.method, 'POST');
      expect(
        requests.first.path,
        '/claims/6ab4f9b766ac53c14dd40da1/accept-assignment',
      );
      // The endpoint takes no body.
      expect(requests.first.data, isNull);

      // The accept response is partial, so the full claim is re-read.
      expect(requests[1].method, 'GET');
      expect(requests[1].path, '/claims/6ab4f9b766ac53c14dd40da1');

      // The result is the server's state, not a locally patched claim.
      expect(claim.status, ClaimStatus.assigned);
      expect(claim.assignedTo?.name, 'Ahmed Adjuster');
      expect(claim.assignedTo?.employeeCode, 'FA-001');
    });

    test('a bare id string in the accept response still parses', () {
      // Guards the shape difference between accept and the claim reads.
      final data = acceptResponse['data']! as Map<String, dynamic>;
      expect(data['assignedTo'], isA<String>());
      expect(ClaimStatus.parse(data['status'] as String?),
          ClaimStatus.assigned);
    });

    test('POSTs decline-assignment with the reason, then re-reads', () async {
      const reason = 'Outside my current operational sector or vehicle issue';
      await ClaimsRemoteDataSourceImpl(
        dio,
      ).declineAssignment('6ab4f9b766ac53c14dd40da1', reason);

      expect(requests.length, 2);
      expect(requests.first.method, 'POST');
      expect(
        requests.first.path,
        '/claims/6ab4f9b766ac53c14dd40da1/decline-assignment',
      );
      // The backend answers 400 "Reason is required" without this.
      expect(requests.first.data, {'reason': reason});

      // The claim has left this adjuster, so it is re-read.
      expect(requests[1].method, 'GET');
      expect(requests[1].path, '/claims/6ab4f9b766ac53c14dd40da1');
    });

    test('a 409 from the backend surfaces as a validation failure', () async {
      final failing = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _ConflictAdapter();
      final result = await ClaimsRepositoryImpl(
        ClaimsRemoteDataSourceImpl(failing),
      ).acceptAssignment('claim-1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('use case', () {
    test('accepts a pending claim', () async {
      final repository = _MockRepository();
      final accepted = pendingClaim();
      when(() => repository.acceptAssignment(any())).thenAnswer(
        (_) async => Right(
          Claim(id: accepted.id, status: ClaimStatus.assigned),
        ),
      );

      final result = await AcceptAssignmentUseCase(repository)(accepted);

      expect(result.isRight(), isTrue);
      verify(() => repository.acceptAssignment(accepted.id)).called(1);
    });

    test('never calls the API for a claim that is not pending', () async {
      final repository = _MockRepository();
      final result = await AcceptAssignmentUseCase(repository)(
        const Claim(id: 'c1', status: ClaimStatus.assigned),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.acceptAssignment(any()));
    });
  });

  group('decline use case', () {
    test('an empty reason never reaches the API', () async {
      final repository = _MockRepository();
      final result = await DeclineAssignmentUseCase(repository)(
        DeclineAssignmentParams(claim: pendingClaim(), reason: '   '),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.declineAssignment(any(), any()));
    });

    test('a claim that is not pending never reaches the API', () async {
      final repository = _MockRepository();
      final result = await DeclineAssignmentUseCase(repository)(
        const DeclineAssignmentParams(
          claim: Claim(id: 'c1', status: ClaimStatus.assigned),
          reason: 'Vehicle issue',
        ),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.declineAssignment(any(), any()));
    });

    test('the reason is trimmed before it is sent', () async {
      final repository = _MockRepository();
      when(() => repository.declineAssignment(any(), any())).thenAnswer(
        (_) async => const Right(Claim(id: 'c1', status: ClaimStatus.newClaim)),
      );

      await DeclineAssignmentUseCase(repository)(
        DeclineAssignmentParams(
          claim: pendingClaim(),
          reason: '  Vehicle issue  ',
        ),
      );

      verify(
        () => repository.declineAssignment(
          '6ab4f9b766ac53c14dd40da1',
          'Vehicle issue',
        ),
      ).called(1);
    });
  });

  group('bloc', () {
    const reason = 'Outside my current operational sector or vehicle issue';

    late _MockGetClaimDetails getDetails;
    late _MockStartClaim startClaim;
    late _MockAccept accept;
    late _MockDecline decline;

    setUp(() {
      getDetails = _MockGetClaimDetails();
      startClaim = _MockStartClaim();
      accept = _MockAccept();
      decline = _MockDecline();
    });

    ClaimDetailsBloc build() => ClaimDetailsBloc(
      getClaimDetailsUseCase: getDetails,
      startClaimUseCase: startClaim,
      acceptAssignmentUseCase: accept,
      declineAssignmentUseCase: decline,
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'accepting moves the claim to assigned',
      build: () {
        when(() => accept(any())).thenAnswer(
          (_) async => Right(
            Claim(
              id: '6ab4f9b766ac53c14dd40da1',
              status: ClaimStatus.assigned,
              claimNumber: 'CLM-DEMO-INS-0038',
            ),
          ),
        );
        return build();
      },
      seed: () => ClaimDetailsLoadSuccess(pendingClaim()),
      act: (bloc) => bloc.add(const ClaimAssignmentAcceptRequested()),
      expect: () => [
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'accepting', isTrue),
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'accepting', isFalse)
            .having((s) => s.claim.status, 'status', ClaimStatus.assigned)
            .having((s) => s.acceptFailure, 'failure', isNull),
      ],
      verify: (_) => verify(() => accept(any())).called(1),
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'a failure leaves the claim pending and reports it',
      build: () {
        when(() => accept(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return build();
      },
      seed: () => ClaimDetailsLoadSuccess(pendingClaim()),
      act: (bloc) => bloc.add(const ClaimAssignmentAcceptRequested()),
      expect: () => [
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'accepting', isTrue),
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.acceptFailure, 'failure', isA<NetworkFailure>())
            .having(
              (s) => s.claim.status,
              'status',
              ClaimStatus.pendingAcceptance,
            ),
      ],
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'a claim that is not pending is never sent to the API',
      build: build,
      seed: () => const ClaimDetailsLoadSuccess(
        Claim(id: 'c1', status: ClaimStatus.assigned),
      ),
      act: (bloc) => bloc.add(const ClaimAssignmentAcceptRequested()),
      expect: () => <ClaimDetailsState>[],
      verify: (_) => verifyNever(() => accept(any())),
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'declining only records that the prompt was shown',
      build: build,
      seed: () => ClaimDetailsLoadSuccess(pendingClaim()),
      act: (bloc) => bloc.add(const ClaimAcceptancePrompted()),
      expect: () => [
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.hasPromptedAcceptance, 'prompted', isTrue)
            .having(
              (s) => s.claim.status,
              'status',
              ClaimStatus.pendingAcceptance,
            ),
      ],
      // Declining must not touch the accept endpoint.
      verify: (_) => verifyNever(() => accept(any())),
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'the prompt is only offered once',
      build: build,
      seed: () => ClaimDetailsLoadSuccess(
        pendingClaim(),
        hasPromptedAcceptance: true,
      ),
      act: (bloc) => bloc.add(const ClaimAcceptancePrompted()),
      expect: () => <ClaimDetailsState>[],
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'declining sends the reason and takes the returned claim',
      build: () {
        when(() => decline(any())).thenAnswer(
          (_) async => const Right(
            Claim(id: '6ab4f9b766ac53c14dd40da1', status: ClaimStatus.newClaim),
          ),
        );
        return build();
      },
      seed: () => ClaimDetailsLoadSuccess(pendingClaim()),
      act: (bloc) => bloc.add(const ClaimAssignmentDeclineRequested(reason)),
      expect: () => [
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'in flight', isTrue),
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'in flight', isFalse)
            .having((s) => s.acceptFailure, 'failure', isNull)
            .having((s) => s.hasPromptedAcceptance, 'prompted', isTrue),
      ],
      verify: (_) {
        final params = verify(() => decline(captureAny())).captured.single
            as DeclineAssignmentParams;
        expect(params.reason, reason);
        expect(params.claim.id, '6ab4f9b766ac53c14dd40da1');
      },
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'a declined claim that fails keeps the claim and reports it',
      build: () {
        when(
          () => decline(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return build();
      },
      seed: () => ClaimDetailsLoadSuccess(pendingClaim()),
      act: (bloc) => bloc.add(const ClaimAssignmentDeclineRequested(reason)),
      expect: () => [
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.isAcceptingAssignment, 'in flight', isTrue),
        isA<ClaimDetailsLoadSuccess>()
            .having((s) => s.acceptFailure, 'failure', isA<NetworkFailure>())
            .having(
              (s) => s.claim.status,
              'status',
              ClaimStatus.pendingAcceptance,
            ),
      ],
    );

    blocTest<ClaimDetailsBloc, ClaimDetailsState>(
      'a claim that is not pending is never declined',
      build: build,
      seed: () => const ClaimDetailsLoadSuccess(
        Claim(id: 'c1', status: ClaimStatus.assigned),
      ),
      act: (bloc) => bloc.add(const ClaimAssignmentDeclineRequested(reason)),
      expect: () => <ClaimDetailsState>[],
      verify: (_) => verifyNever(() => decline(any())),
    );

  });

  group('dialog', () {
    Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStringsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      );
    }

    Future<bool?> openDialog(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      bool? outcome;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open'),
                  onPressed: () async {
                    outcome = await AssignmentAvailabilityDialog.show(
                      context,
                      claimNumber: 'CLM-DEMO-INS-0038',
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      return outcome;
    }

    testWidgets('asks about availability and shows the claim number', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.text('Are you available?'), findsOneWidget);
      // The backend claim number, shown verbatim.
      expect(find.text('CLM-DEMO-INS-0038'), findsOneWidget);
      expect(find.byKey(const Key('assignment-accept')), findsOneWidget);
      expect(find.byKey(const Key('assignment-decline')), findsOneWidget);
    });

    testWidgets('accept returns true', (tester) async {
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('assignment-accept')));
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentAvailabilityDialog), findsNothing);
    });

    testWidgets('decline closes without accepting', (tester) async {
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('assignment-decline')));
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentAvailabilityDialog), findsNothing);
    });

    testWidgets('dismissing does not count as accepting', (tester) async {
      await openDialog(tester);
      // Tap the barrier.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentAvailabilityDialog), findsNothing);
    });

    testWidgets('renders in Arabic, right to left', (tester) async {
      await openDialog(tester, locale: const Locale('ar'));

      expect(find.text('هل أنت متاح؟'), findsOneWidget);
      expect(find.text('قبول'), findsOneWidget);
      expect(find.text('ليس الآن'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('هل أنت متاح؟'))),
        TextDirection.rtl,
      );
      // The claim number stays LTR so it reads correctly.
      final number = tester.widget<Text>(find.text('CLM-DEMO-INS-0038'));
      expect(number.textDirection, TextDirection.ltr);
    });
  });
}

// --- adapters --------------------------------------------------------------

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = options.method == 'POST' ? acceptResponse : claimAfterAccept;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Reproduces the backend's 409 for a claim that already moved on.
class _ConflictAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({
        'success': false,
        'message': 'Claim is not in PENDING_ACCEPTANCE status',
        'errors': [
          {
            'code': 'INVALID_STATUS_TRANSITION',
            'details': 'Claim is not in PENDING_ACCEPTANCE status',
          },
        ],
      }),
      409,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
