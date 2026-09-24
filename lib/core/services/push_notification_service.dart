import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:insurflow/core/services/push_messaging_gateway.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';
import 'package:insurflow/features/notifications/domain/usecases/register_device_token.dart';

/// Handles a push delivered while the app is backgrounded or terminated.
///
/// Must be a top-level, `vm:entry-point` function: Android runs it in a
/// separate isolate with no access to app state, which is why it only
/// logs. The system tray entry for such a message is drawn by the
/// platform from the FCM `notification` block, and if the user taps it
/// the message is re-delivered through `onMessageOpenedApp` (app alive)
/// or `getInitialMessage` (app was killed) — that is where navigation
/// happens.
@pragma('vm:entry-point')
Future<void> insurFlowBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[push] background message ${message.messageId}');
  }
}

/// Wires Firebase Cloud Messaging into the app.
///
/// * asks for permission (iOS prompt, Android 13+ POST_NOTIFICATIONS);
/// * obtains the FCM token and keeps the backend in sync through
///   `PATCH /users/me/fcm-token`, including on refresh;
/// * draws a banner for foreground messages, which FCM does not do
///   itself on Android;
/// * surfaces taps from all three app states as one stream.
///
/// No payload field is invented: `title`/`body` come from the FCM
/// `notification` block, and the backend's `data` map is passed to
/// [AppNotification], which navigates only when it finds a value shaped
/// like a real claim id.
class PushNotificationService {
  PushNotificationService({
    required RegisterDeviceTokenUseCase registerDeviceTokenUseCase,
    PushMessagingGateway? gateway,
    NotificationPresenter? presenter,
  }) : _registerDeviceTokenUseCase = registerDeviceTokenUseCase,
       _injectedGateway = gateway,
       _injectedPresenter = presenter;

  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;
  final PushMessagingGateway? _injectedGateway;
  final NotificationPresenter? _injectedPresenter;

  // Built on first use so that constructing the service — which happens
  // during dependency setup, before `Firebase.initializeApp` — never
  // touches a Firebase plugin.
  late final PushMessagingGateway _gateway =
      _injectedGateway ?? FirebaseMessagingGateway();
  late final NotificationPresenter _presenter =
      _injectedPresenter ?? LocalNotificationPresenter();

  final _received = StreamController<AppNotification>.broadcast();
  final _opened = StreamController<AppNotification>.broadcast();

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  var _isInitialised = false;
  String? _lastRegisteredToken;
  AuthorizationStatus? _authorizationStatus;

  /// Pushes received while the app is in the foreground.
  Stream<AppNotification> get onNotificationReceived => _received.stream;

  /// Pushes the user tapped, from any app state.
  Stream<AppNotification> get onNotificationOpened => _opened.stream;

  /// Null until permission has been resolved.
  AuthorizationStatus? get authorizationStatus => _authorizationStatus;

  bool get isAuthorized =>
      _authorizationStatus == AuthorizationStatus.authorized ||
      _authorizationStatus == AuthorizationStatus.provisional;

  /// The token most recently accepted by the backend, if any.
  String? get lastRegisteredToken => _lastRegisteredToken;

  /// Sets up listeners and the notification channel.
  ///
  /// Idempotent. It does not register the token, because
  /// `PATCH /users/me/fcm-token` needs a signed-in user — [syncToken] is
  /// called after login instead.
  Future<void> init() async {
    if (_isInitialised) return;
    _isInitialised = true;

    await _safely('initializePresenter', () async {
      await _presenter.initialize(_onLocalNotificationTapped);
    });

    await requestPermission();

    _onMessageSub = _gateway.onMessage.listen(_handleForeground);
    _onOpenedSub = _gateway.onMessageOpenedApp.listen((message) {
      _opened.add(_toNotification(message));
    });
    _onTokenRefreshSub = _gateway.onTokenRefresh.listen(_onTokenRefreshed);

    await _safely('setForegroundPresentationOptions', () async {
      await _gateway.setForegroundPresentationOptions();
    });
  }

  /// Asks for permission and records the outcome.
  ///
  /// A denial is a normal outcome, not an error: the app keeps working
  /// and no token is registered.
  Future<AuthorizationStatus> requestPermission() async {
    try {
      _authorizationStatus = await _gateway.requestPermission();
    } catch (error, stack) {
      _logError('requestPermission', error, stack);
      _authorizationStatus = AuthorizationStatus.notDetermined;
    }
    return _authorizationStatus!;
  }

  /// Fetches the FCM token and registers it with the backend.
  ///
  /// Repeated calls with an unchanged token do not hit the network.
  /// Registration is skipped when notifications are not permitted,
  /// since the device would never be delivered to.
  Future<void> syncToken({bool force = false}) async {
    if (_authorizationStatus != null && !isAuthorized) return;
    try {
      final token = await _gateway.getToken();
      if (token == null || token.trim().isEmpty) return;
      if (!force && token == _lastRegisteredToken) return;
      await _register(token);
    } catch (error, stack) {
      // Play Services missing, offline, APNs not configured — none of
      // which should disturb the session.
      _logError('syncToken', error, stack);
    }
  }

  /// Re-registers whenever Firebase rotates the token.
  Future<void> _onTokenRefreshed(String token) async {
    // A rotated token is new by definition, so bypass the cache.
    _lastRegisteredToken = null;
    await _register(token);
  }

  Future<void> _register(String token) async {
    final result = await _registerDeviceTokenUseCase(token);
    result.fold(
      (failure) => _logError('registerDeviceToken', failure, null),
      (_) => _lastRegisteredToken = token,
    );
  }

  /// Forgets the cached token so the next [syncToken] re-sends it. The
  /// backend exposes no way to detach a token, so signing out cannot
  /// unregister the device.
  void forgetRegisteredToken() => _lastRegisteredToken = null;

  /// Drains the message that launched the app from a terminated state.
  Future<AppNotification?> handleInitialMessage() async {
    try {
      final message = await _gateway.getInitialMessage();
      if (message == null) return null;
      final notification = _toNotification(message);
      _opened.add(notification);
      return notification;
    } catch (error, stack) {
      _logError('handleInitialMessage', error, stack);
      return null;
    }
  }

  Future<void> _handleForeground(RemoteMessage message) async {
    final notification = _toNotification(message);
    // A silent data-only message carries no text to show, but may still
    // be meaningful to the backend; it is simply not displayed.
    if (!notification.isDisplayable) return;

    _received.add(notification);
    await _safely('showNotification', () async {
      await _presenter.show(
        // Stable, non-negative 31-bit id so a repeated delivery
        // replaces rather than stacks.
        id: notification.id.hashCode & 0x7fffffff,
        title: notification.title,
        body: notification.body,
        payload: jsonEncode({
          ...notification.data,
          _payloadId: notification.id,
          if (notification.title != null) _payloadTitle: notification.title,
          if (notification.body != null) _payloadBody: notification.body,
        }),
      );
    });
  }

  /// Builds an [AppNotification], tolerating every part being absent.
  AppNotification _toNotification(RemoteMessage message) {
    final data = <String, String>{
      for (final entry in message.data.entries)
        entry.key.toString(): entry.value?.toString() ?? '',
    };

    return AppNotification(
      // A message without an id still needs a stable identity for
      // de-duplication and for the local notification id.
      id:
          message.messageId ??
          'local-${DateTime.now().microsecondsSinceEpoch}',
      receivedAt: DateTime.now(),
      title:
          message.notification?.title ??
          AppNotification.resolveText(data, AppNotification.titleKeys),
      body:
          message.notification?.body ??
          AppNotification.resolveText(data, AppNotification.bodyKeys),
      claimId: AppNotification.resolveClaimId(data),
      sentAt: message.sentTime,
      data: data,
    );
  }

  /// A tap on the banner drawn for a foreground message.
  void _onLocalNotificationTapped(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final data = <String, String>{
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
      };
      _opened.add(
        AppNotification(
          id:
              data[_payloadId] ??
              'local-${DateTime.now().microsecondsSinceEpoch}',
          receivedAt: DateTime.now(),
          title: data[_payloadTitle],
          body: data[_payloadBody],
          claimId: AppNotification.resolveClaimId(data),
          data: data,
        ),
      );
    } catch (error, stack) {
      // A malformed payload must never crash the tap handler.
      _logError('onLocalNotificationTapped', error, stack);
    }
  }

  // Reserved keys used to round-trip the notification through the local
  // plugin's string payload. Prefixed so they cannot collide with a
  // backend field.
  static const _payloadId = '__insurflow_id';
  static const _payloadTitle = '__insurflow_title';
  static const _payloadBody = '__insurflow_body';

  Future<void> _safely(String context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      _logError(context, error, stack);
    }
  }

  void _logError(String context, Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('[push] $context failed: $error');
      if (stack != null) debugPrint('$stack');
    }
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    await _received.close();
    await _opened.close();
  }
}
