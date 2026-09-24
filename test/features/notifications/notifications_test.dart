import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/services/push_messaging_gateway.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:insurflow/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';
import 'package:insurflow/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:insurflow/features/notifications/domain/usecases/register_device_token.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:insurflow/features/notifications/presentation/widgets/notification_tile.dart';

const claimId = '6ab3a2de8acb6d762af8d57b';
const otherObjectId = '6aa27838cda4d3dca00b83ad';

AppNotification _notification({
  String id = 'n1',
  String? title = 'New assignment',
  String? body = 'A claim was assigned to you',
  String? claim,
}) {
  return AppNotification(
    id: id,
    receivedAt: DateTime(2026, 9, 24, 10),
    title: title,
    body: body,
    claimId: claim,
  );
}

void main() {
  group('payload parsing', () {
    test('finds a claim id under the documented-looking keys', () {
      for (final key in ['claimId', 'claim_id', 'claim', 'id']) {
        expect(
          AppNotification.resolveClaimId({key: claimId}),
          claimId,
          reason: key,
        );
      }
    });

    test('prefers an explicit claim key over another ObjectId', () {
      final resolved = AppNotification.resolveClaimId({
        'actorId': otherObjectId,
        'claimId': claimId,
      });
      expect(resolved, claimId);
    });

    test('falls back to any value shaped like a claim id', () {
      // The backend may name the field something this app has not seen;
      // the value format is what is actually verified.
      expect(
        AppNotification.resolveClaimId({'somethingElse': claimId}),
        claimId,
      );
    });

    test('returns null when nothing looks like a claim id', () {
      expect(AppNotification.resolveClaimId(const {}), isNull);
      expect(
        AppNotification.resolveClaimId(const {'claimId': 'CLM-DEMO-INS-0031'}),
        isNull,
      );
      expect(AppNotification.resolveClaimId(const {'claimId': ''}), isNull);
      expect(AppNotification.resolveClaimId(const {'claimId': '123'}), isNull);
      // 23 characters: one short of an ObjectId.
      expect(
        AppNotification.resolveClaimId({'claimId': claimId.substring(1)}),
        isNull,
      );
    });

    test('a notification with neither title nor body is not displayable', () {
      expect(_notification(title: null, body: null).isDisplayable, isFalse);
      expect(_notification(title: '  ', body: '  ').isDisplayable, isFalse);
      expect(_notification(title: null).isDisplayable, isTrue);
    });
  });

  group('device token API', () {
    late Dio dio;
    late List<RequestOptions> requests;

    setUp(() {
      requests = [];
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
      dio.httpClientAdapter = _StubAdapter(requests);
    });

    test('PATCHes the exact contract the backend validates', () async {
      await NotificationsRemoteDataSourceImpl(dio).updateFcmToken('abc123');

      expect(requests.single.method, 'PATCH');
      expect(requests.single.path, '/users/me/fcm-token');
      // The schema is strict: `fcmToken` only.
      expect(requests.single.data, {'fcmToken': 'abc123'});
    });

    test('maps a transport failure instead of throwing', () async {
      final failing = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _FailingAdapter();
      final repository = NotificationsRepositoryImpl(
        NotificationsRemoteDataSourceImpl(failing),
      );

      final result = await repository.registerDeviceToken('abc');
      expect(result.isLeft(), isTrue);
    });

    test('an empty token never reaches the network', () async {
      final repository = _RecordingRepository();
      final result = await RegisterDeviceTokenUseCase(repository)('   ');

      expect(result.isLeft(), isTrue);
      expect(repository.calls, isEmpty);
    });
  });

  group('notification centre', () {
    late _StubGateway gateway;
    late PushNotificationService service;
    late NotificationCenterCubit cubit;

    setUp(() async {
      gateway = _StubGateway();
      service = PushNotificationService(
        registerDeviceTokenUseCase: RegisterDeviceTokenUseCase(
          _RecordingRepository(),
        ),
        gateway: gateway,
        presenter: _NoopPresenter(),
      );
      cubit = NotificationCenterCubit(service: service);
    });

    tearDown(() async {
      await cubit.close();
      await service.dispose();
      await gateway.close();
    });

    test('starts empty — there is no history endpoint to load from', () {
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
    });

    test('collects multiple notifications newest first', () {
      cubit.add(_notification(id: 'a', title: 'First'));
      cubit.add(_notification(id: 'b', title: 'Second'));

      expect(
        cubit.state.notifications.map((item) => item.title),
        ['Second', 'First'],
      );
      expect(cubit.state.unreadCount, 2);
    });

    test('ignores a duplicate delivery of the same message', () {
      cubit.add(_notification(id: 'a'));
      cubit.add(_notification(id: 'a'));

      expect(cubit.state.notifications.length, 1);
    });

    test('drops a message with nothing to show', () {
      cubit.add(_notification(id: 'a', title: null, body: null));
      expect(cubit.state.notifications, isEmpty);
    });

    test('marking read reduces the unread count', () {
      final first = _notification(id: 'a');
      cubit.add(first);
      cubit.add(_notification(id: 'b'));

      cubit.markRead(first);
      expect(cubit.state.unreadCount, 1);

      cubit.markAllRead();
      expect(cubit.state.unreadCount, 0);
    });

    test('caps the list so a burst cannot grow without bound', () {
      for (var i = 0; i < NotificationCenterCubit.maxItems + 10; i++) {
        cubit.add(_notification(id: 'n$i'));
      }
      expect(
        cubit.state.notifications.length,
        NotificationCenterCubit.maxItems,
      );
    });
  });

  group('notification centre UI', () {
    Widget wrap(NotificationCenterCubit cubit, {Locale locale = const Locale('en')}) {
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
        home: BlocProvider.value(
          value: cubit,
          child: const NotificationCenterScreen(),
        ),
      );
    }

    late _StubGateway gateway;
    late PushNotificationService service;
    late NotificationCenterCubit cubit;

    setUp(() {
      gateway = _StubGateway();
      service = PushNotificationService(
        registerDeviceTokenUseCase: RegisterDeviceTokenUseCase(
          _RecordingRepository(),
        ),
        gateway: gateway,
        presenter: _NoopPresenter(),
      );
      cubit = NotificationCenterCubit(service: service);
    });

    tearDown(() async {
      await cubit.close();
      await service.dispose();
      await gateway.close();
    });

    testWidgets('empty state says so rather than showing placeholders', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(cubit));
      await tester.pump();

      expect(find.text('No notifications'), findsOneWidget);
      expect(find.byType(NotificationTile), findsNothing);
    });

    testWidgets('renders received notifications and marks all read', (
      tester,
    ) async {
      cubit.add(_notification(id: 'a', title: 'New assignment', claim: claimId));
      cubit.add(_notification(id: 'b', title: 'Correction required'));

      await tester.pumpWidget(wrap(cubit));
      await tester.pump();

      expect(find.byType(NotificationTile), findsNWidgets(2));
      expect(find.text('New assignment'), findsOneWidget);
      // Only the one carrying a claim id offers navigation.
      expect(find.text('View claim'), findsOneWidget);

      await tester.tap(find.byKey(const Key('notifications-mark-all-read')));
      await tester.pump();

      expect(cubit.state.unreadCount, 0);
    });

    testWidgets('a notification with no claim explains why nothing opened', (
      tester,
    ) async {
      cubit.add(_notification(id: 'a', title: 'System message'));

      await tester.pumpWidget(wrap(cubit));
      await tester.pump();

      await tester.tap(find.byType(NotificationTile));
      await tester.pump();

      expect(
        find.text('This notification has no linked claim.'),
        findsOneWidget,
      );
    });

    testWidgets('permission denial is surfaced with a retry action', (
      tester,
    ) async {
      gateway.permission = AuthorizationStatus.denied;
      await service.requestPermission();
      cubit.refreshPermission();

      await tester.pumpWidget(wrap(cubit));
      await tester.pump();

      expect(
        find.byKey(const Key('notifications-permission-banner')),
        findsOneWidget,
      );
      expect(find.text('Notifications are off'), findsOneWidget);
      expect(find.byKey(const Key('notifications-enable')), findsOneWidget);
    });

    testWidgets('renders in Arabic', (tester) async {
      await tester.pumpWidget(wrap(cubit, locale: const Locale('ar')));
      await tester.pump();

      expect(find.text('لا توجد إشعارات'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('لا توجد إشعارات'))),
        TextDirection.rtl,
      );
    });
  });
}

// --- doubles ---------------------------------------------------------------

/// Minimal gateway that reports a permission result and never emits.
class _StubGateway implements PushMessagingGateway {
  final _message = StreamController<RemoteMessage>.broadcast();
  final _opened = StreamController<RemoteMessage>.broadcast();
  final _tokenRefresh = StreamController<String>.broadcast();

  AuthorizationStatus permission = AuthorizationStatus.authorized;

  @override
  Stream<RemoteMessage> get onMessage => _message.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => _opened.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenRefresh.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<String?> getToken() async => 'token';

  @override
  Future<AuthorizationStatus> requestPermission() async => permission;

  @override
  Future<void> setForegroundPresentationOptions() async {}

  Future<void> close() async {
    await _message.close();
    await _opened.close();
    await _tokenRefresh.close();
  }
}

class _RecordingRepository implements NotificationsRepository {
  final calls = <String>[];

  @override
  Future<Either<Failure, void>> registerDeviceToken(String fcmToken) async {
    calls.add(fcmToken);
    return const Right(null);
  }
}

class _NoopPresenter implements NotificationPresenter {
  @override
  Future<void> initialize(void Function(String? payload) onTap) async {}

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {}
}

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
    return ResponseBody.fromString(
      '{"success":true,"message":"Device token updated successfully",'
      '"data":{"id":"u1","fcmToken":"abc123"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
    );
  }
}
