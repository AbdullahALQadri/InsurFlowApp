import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/services/push_messaging_gateway.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';
import 'package:insurflow/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:insurflow/features/notifications/domain/usecases/register_device_token.dart';

/// A real claim id from the live API — the format the payload parser
/// recognises.
const claimId = '6ab3a2de8acb6d762af8d57b';

class _FakeGateway implements PushMessagingGateway {
  final message = StreamController<RemoteMessage>.broadcast();
  final opened = StreamController<RemoteMessage>.broadcast();
  final tokenRefresh = StreamController<String>.broadcast();

  String? token = 'fcm-token-1';
  AuthorizationStatus permission = AuthorizationStatus.authorized;
  RemoteMessage? initialMessage;
  var throwOnGetToken = false;
  var permissionRequests = 0;
  var getTokenCalls = 0;

  @override
  Stream<RemoteMessage> get onMessage => message.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => opened.stream;

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<String?> getToken() async {
    getTokenCalls++;
    if (throwOnGetToken) throw StateError('no play services');
    return token;
  }

  @override
  Future<AuthorizationStatus> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> setForegroundPresentationOptions() async {}

  Future<void> close() async {
    await message.close();
    await opened.close();
    await tokenRefresh.close();
  }
}

class _FakePresenter implements NotificationPresenter {
  final shown = <Map<String, Object?>>[];
  void Function(String? payload)? _onTap;

  @override
  Future<void> initialize(void Function(String? payload) onTap) async {
    _onTap = onTap;
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    shown.add({'id': id, 'title': title, 'body': body, 'payload': payload});
  }

  /// Simulates the user tapping the banner that was just drawn.
  void tapLast() => _onTap?.call(shown.last['payload'] as String?);
}

class _FakeRepository implements NotificationsRepository {
  _FakeRepository({this.failure});

  final Failure? failure;
  final registered = <String>[];

  @override
  Future<Either<Failure, void>> registerDeviceToken(String fcmToken) async {
    registered.add(fcmToken);
    final error = failure;
    return error == null ? const Right(null) : Left(error);
  }
}

RemoteMessage _message({
  String? id = 'msg-1',
  String? title = 'New assignment',
  String? body = 'Claim CLM-DEMO-INS-0031 assigned to you',
  Map<String, dynamic> data = const {},
}) {
  return RemoteMessage(
    messageId: id,
    data: data,
    notification: (title == null && body == null)
        ? null
        : RemoteNotification(title: title, body: body),
  );
}

void main() {
  late _FakeGateway gateway;
  late _FakePresenter presenter;
  late _FakeRepository repository;
  late PushNotificationService service;

  PushNotificationService build({Failure? failure}) {
    repository = _FakeRepository(failure: failure);
    return PushNotificationService(
      registerDeviceTokenUseCase: RegisterDeviceTokenUseCase(repository),
      gateway: gateway,
      presenter: presenter,
    );
  }

  setUp(() {
    gateway = _FakeGateway();
    presenter = _FakePresenter();
    service = build();
  });

  tearDown(() async {
    await service.dispose();
    await gateway.close();
  });

  group('permission', () {
    test('records an authorized result and allows token registration', () async {
      await service.init();

      expect(gateway.permissionRequests, 1);
      expect(service.isAuthorized, isTrue);

      await service.syncToken();
      expect(repository.registered, ['fcm-token-1']);
    });

    test('denial is handled and no token is registered', () async {
      gateway.permission = AuthorizationStatus.denied;
      await service.init();

      expect(service.authorizationStatus, AuthorizationStatus.denied);
      expect(service.isAuthorized, isFalse);

      await service.syncToken();
      // Registering a device that can never be delivered to is pointless.
      expect(repository.registered, isEmpty);
      expect(gateway.getTokenCalls, 0);
    });

    test('init does not throw when the platform cannot report permission', () async {
      gateway.throwOnGetToken = true;
      await service.init();
      await service.syncToken();

      expect(service.isAuthorized, isTrue);
      expect(repository.registered, isEmpty);
    });
  });

  group('token registration', () {
    test('does not re-send an unchanged token', () async {
      await service.init();

      await service.syncToken();
      await service.syncToken();
      await service.syncToken();

      expect(repository.registered, ['fcm-token-1']);
    });

    test('force re-sends the same token', () async {
      await service.init();
      await service.syncToken();
      await service.syncToken(force: true);

      expect(repository.registered, ['fcm-token-1', 'fcm-token-1']);
    });

    test('a refreshed token is registered immediately', () async {
      await service.init();
      await service.syncToken();

      gateway.tokenRefresh.add('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registered, ['fcm-token-1', 'fcm-token-2']);
      expect(service.lastRegisteredToken, 'fcm-token-2');
    });

    test('a failed registration is not cached, so it is retried', () async {
      service = build(failure: const NetworkFailure());
      await service.init();

      await service.syncToken();
      await service.syncToken();

      expect(repository.registered, ['fcm-token-1', 'fcm-token-1']);
      expect(service.lastRegisteredToken, isNull);
    });

    test('signing out clears the cache so the next login re-registers', () async {
      await service.init();
      await service.syncToken();
      expect(repository.registered.length, 1);

      service.forgetRegisteredToken();
      await service.syncToken();

      expect(repository.registered.length, 2);
    });

    test('an empty token is never sent to the backend', () async {
      gateway.token = '   ';
      await service.init();
      await service.syncToken();

      expect(repository.registered, isEmpty);
    });
  });

  group('app open (foreground delivery)', () {
    test('publishes the message and draws a banner', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(
        _message(data: const {'claimId': claimId}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received.length, 1);
      expect(received.single.title, 'New assignment');
      expect(received.single.claimId, claimId);
      expect(presenter.shown.length, 1);
      expect(presenter.shown.single['title'], 'New assignment');
    });

    test('a silent data-only message is not displayed', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(
        _message(title: null, body: null, data: const {'claimId': claimId}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
      expect(presenter.shown, isEmpty);
    });

    test('reads title and body from data when there is no notification block', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(
        _message(
          title: null,
          body: null,
          data: const {'title': 'Correction required', 'body': 'Re-check photos'},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received.single.title, 'Correction required');
      expect(received.single.body, 'Re-check photos');
    });

    test('tapping the foreground banner opens the claim', () async {
      await service.init();
      final opened = <AppNotification>[];
      service.onNotificationOpened.listen(opened.add);

      gateway.message.add(_message(data: const {'claimId': claimId}));
      await Future<void>.delayed(Duration.zero);

      presenter.tapLast();
      await Future<void>.delayed(Duration.zero);

      expect(opened.single.claimId, claimId);
      expect(opened.single.title, 'New assignment');
    });
  });

  group('app in background', () {
    test('a tap is surfaced with its claim id', () async {
      await service.init();
      final opened = <AppNotification>[];
      service.onNotificationOpened.listen(opened.add);

      gateway.opened.add(_message(data: const {'claimId': claimId}));
      await Future<void>.delayed(Duration.zero);

      expect(opened.single.claimId, claimId);
    });
  });

  group('app terminated', () {
    test('the launching message is drained once', () async {
      gateway.initialMessage = _message(data: const {'claimId': claimId});
      await service.init();

      final opened = <AppNotification>[];
      service.onNotificationOpened.listen(opened.add);

      final result = await service.handleInitialMessage();
      // Broadcast listeners are notified asynchronously.
      await Future<void>.delayed(Duration.zero);

      expect(result?.claimId, claimId);
      expect(opened.single.claimId, claimId);
    });

    test('no launching message yields null', () async {
      await service.init();
      expect(await service.handleInitialMessage(), isNull);
    });
  });

  group('incomplete payloads do not crash', () {
    test('no data at all', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(_message());
      await Future<void>.delayed(Duration.zero);

      expect(received.single.claimId, isNull);
      expect(received.single.hasDestination, isFalse);
    });

    test('data present but no claim id', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(
        _message(data: const {'type': 'ASSIGNMENT', 'claimId': 'not-an-id'}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received.single.claimId, isNull);
      expect(received.single.data['type'], 'ASSIGNMENT');
    });

    test('missing messageId still produces a usable notification', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(_message(id: null));
      await Future<void>.delayed(Duration.zero);

      expect(received.single.id, isNotEmpty);
    });

    test('a malformed banner payload is ignored', () async {
      await service.init();
      final opened = <AppNotification>[];
      service.onNotificationOpened.listen(opened.add);

      presenter.shown.add({'payload': 'not-json{{'});
      presenter.tapLast();
      await Future<void>.delayed(Duration.zero);

      expect(opened, isEmpty);
    });

    test('null values in the data map are tolerated', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(_message(data: const {'claimId': null}));
      await Future<void>.delayed(Duration.zero);

      expect(received.single.claimId, isNull);
      expect(received.single.data['claimId'], '');
    });
  });

  group('multiple notifications', () {
    test('each is published and drawn with its own id', () async {
      await service.init();
      final received = <AppNotification>[];
      service.onNotificationReceived.listen(received.add);

      gateway.message.add(_message(id: 'a', title: 'First'));
      gateway.message.add(_message(id: 'b', title: 'Second'));
      gateway.message.add(_message(id: 'c', title: 'Third'));
      await Future<void>.delayed(Duration.zero);

      expect(received.map((item) => item.title), ['First', 'Second', 'Third']);
      expect(presenter.shown.length, 3);
      // Distinct, non-negative ids so banners do not overwrite each other.
      final ids = presenter.shown.map((item) => item['id'] as int).toSet();
      expect(ids.length, 3);
      expect(ids.every((id) => id >= 0), isTrue);
    });

    test('the same message delivered twice keeps a stable banner id', () async {
      await service.init();

      gateway.message.add(_message(id: 'dup'));
      gateway.message.add(_message(id: 'dup'));
      await Future<void>.delayed(Duration.zero);

      expect(presenter.shown[0]['id'], presenter.shown[1]['id']);
    });
  });

  group('banner payload round-trip', () {
    test('carries the backend data plus the reserved keys', () async {
      await service.init();

      gateway.message.add(
        _message(data: const {'claimId': claimId, 'type': 'ASSIGNMENT'}),
      );
      await Future<void>.delayed(Duration.zero);

      final payload =
          jsonDecode(presenter.shown.single['payload']! as String) as Map;
      expect(payload['claimId'], claimId);
      expect(payload['type'], 'ASSIGNMENT');
      expect(payload['__insurflow_id'], 'msg-1');
    });
  });
}
