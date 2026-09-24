import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The Firebase Messaging surface the app actually uses.
///
/// `FirebaseMessaging.onMessage`, `onMessageOpenedApp` and
/// `getInitialMessage` are static, so they cannot be substituted in a
/// test. Putting them behind this seam lets the foreground, background
/// and terminated paths be exercised without a device.
abstract class PushMessagingGateway {
  /// Pushes delivered while the app is in the foreground.
  Stream<RemoteMessage> get onMessage;

  /// Taps on a notification while the app was in the background.
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// Emits whenever Firebase rotates the registration token.
  Stream<String> get onTokenRefresh;

  /// The message that launched the app from a terminated state.
  Future<RemoteMessage?> getInitialMessage();

  Future<String?> getToken();

  Future<AuthorizationStatus> requestPermission();

  /// iOS-only; a no-op elsewhere.
  Future<void> setForegroundPresentationOptions();
}

class FirebaseMessagingGateway implements PushMessagingGateway {
  FirebaseMessagingGateway({FirebaseMessaging? messaging})
    : _injected = messaging;

  final FirebaseMessaging? _injected;

  /// Resolved lazily: `FirebaseMessaging.instance` throws until
  /// `Firebase.initializeApp` has run, and this gateway is constructed
  /// during dependency setup, which happens first.
  FirebaseMessaging get _messaging => _injected ?? FirebaseMessaging.instance;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus;
  }

  @override
  Future<void> setForegroundPresentationOptions() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

/// Draws the banner for a message that arrives in the foreground, which
/// FCM does not do by itself on Android.
abstract class NotificationPresenter {
  /// [onTap] receives the payload attached to the shown notification.
  Future<void> initialize(void Function(String? payload) onTap);

  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  });
}

class LocalNotificationPresenter implements NotificationPresenter {
  LocalNotificationPresenter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Matches the channel declared in AndroidManifest.xml as
  /// `default_notification_channel_id`, so a foreground banner and a
  /// tray entry from the background behave identically.
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'insurflow_claims',
    'Claim updates',
    description: 'Assignment and claim status notifications.',
    importance: Importance.high,
  );

  @override
  Future<void> initialize(void Function(String? payload) onTap) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Permission is requested once through FirebaseMessaging so the
        // user is not prompted twice.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) => onTap(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
    return _plugin.show(id, title, body, details, payload: payload);
  }
}
