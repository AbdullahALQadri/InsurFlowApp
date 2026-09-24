import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';

/// Connects push notifications to the app: keeps the backend's copy of
/// the FCM token current, and turns a notification tap into navigation.
///
/// Sits under [MaterialApp.builder] so it can push onto the app's
/// navigator from a callback that originates outside the widget tree.
///
/// Three delivery states all land here:
/// * **foreground** — the service draws a banner; tapping it emits on
///   `onNotificationOpened`;
/// * **background** — `onMessageOpenedApp` emits when the user taps the
///   system tray entry;
/// * **terminated** — `getInitialMessage` is drained once on startup.
class NotificationGateway extends StatefulWidget {
  const NotificationGateway({
    super.key,
    required this.service,
    required this.navigatorKey,
    required this.child,
  });

  final PushNotificationService service;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<NotificationGateway> createState() => _NotificationGatewayState();
}

class _NotificationGatewayState extends State<NotificationGateway> {
  StreamSubscription<AppNotification>? _openedSub;

  @override
  void initState() {
    super.initState();
    _openedSub = widget.service.onNotificationOpened.listen(_navigate);

    // Drain the message that launched the app from a terminated state.
    // Deferred to the first frame so a navigator exists to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(widget.service.handleInitialMessage());
    });
  }

  @override
  void dispose() {
    _openedSub?.cancel();
    super.dispose();
  }

  /// Opens the claim a notification points at.
  ///
  /// A payload without a recognisable claim id is not an error: the
  /// message is still recorded in the notification list, and the app
  /// simply stays where it is instead of pushing an empty screen.
  void _navigate(AppNotification notification) {
    final claimId = notification.claimId;
    if (claimId == null || claimId.isEmpty) return;

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    ClaimDetailsScreen.open(navigator.context, claimId: claimId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // `PATCH /users/me/fcm-token` needs a bearer token, so the
          // device can only be registered once a session exists.
          unawaited(widget.service.syncToken());
        } else if (state is AuthUnauthenticated) {
          // The backend offers no way to detach a token, so signing out
          // only clears the local cache; the next sign-in re-sends it.
          widget.service.forgetRegisteredToken();
        }
      },
      child: widget.child,
    );
  }
}
