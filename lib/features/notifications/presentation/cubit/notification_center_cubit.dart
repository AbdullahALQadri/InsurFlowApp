import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';

class NotificationCenterState {
  const NotificationCenterState({
    this.notifications = const [],
    this.readIds = const {},
    this.permissionGranted = true,
  });

  /// Newest first.
  final List<AppNotification> notifications;
  final Set<String> readIds;

  /// False once the OS has told us notifications are not permitted.
  /// Starts true so the warning is not shown before permission has
  /// actually been resolved.
  final bool permissionGranted;

  int get unreadCount =>
      notifications.where((item) => !readIds.contains(item.id)).length;

  bool isRead(AppNotification notification) => readIds.contains(notification.id);

  NotificationCenterState copyWith({
    List<AppNotification>? notifications,
    Set<String>? readIds,
    bool? permissionGranted,
  }) {
    return NotificationCenterState(
      notifications: notifications ?? this.notifications,
      readIds: readIds ?? this.readIds,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

/// Holds the pushes this app instance has actually received.
///
/// The backend exposes no notification history endpoint — the only
/// notification-related route is `PATCH /users/me/fcm-token` — so there
/// is nothing to fetch and nothing is fabricated to fill the list. It
/// starts empty and grows as real messages arrive, which also means it
/// does not survive a restart.
class NotificationCenterCubit extends Cubit<NotificationCenterState> {
  NotificationCenterCubit({required PushNotificationService service})
    : _service = service,
      super(const NotificationCenterState()) {
    _receivedSub = _service.onNotificationReceived.listen(add);
    // A tap can arrive for a message this instance never saw in the
    // foreground (background or terminated delivery), so record those
    // too instead of losing them.
    _openedSub = _service.onNotificationOpened.listen((notification) {
      add(notification);
      markRead(notification);
    });
    refreshPermission();
  }

  /// Mirrors the OS permission state into the UI. A denial is a normal
  /// outcome, so it is surfaced as a prompt rather than an error.
  void refreshPermission() {
    final status = _service.authorizationStatus;
    // Null means permission has not been resolved yet; leave the
    // current value alone rather than flashing a warning.
    if (status == null) return;
    emit(state.copyWith(permissionGranted: _service.isAuthorized));
  }

  /// Re-asks the OS, then mirrors the result.
  Future<void> requestPermission() async {
    await _service.requestPermission();
    refreshPermission();
    if (_service.isAuthorized) await _service.syncToken();
  }

  final PushNotificationService _service;
  late final StreamSubscription<AppNotification> _receivedSub;
  late final StreamSubscription<AppNotification> _openedSub;

  static const maxItems = 50;

  void add(AppNotification notification) {
    if (!notification.isDisplayable) return;
    // Android can deliver the same message twice (tray + tap).
    if (state.notifications.any((item) => item.id == notification.id)) return;

    final updated = [notification, ...state.notifications];
    emit(
      state.copyWith(
        notifications: updated.length > maxItems
            ? updated.sublist(0, maxItems)
            : updated,
      ),
    );
  }

  void markRead(AppNotification notification) {
    if (state.readIds.contains(notification.id)) return;
    emit(state.copyWith(readIds: {...state.readIds, notification.id}));
  }

  void markAllRead() {
    if (state.notifications.isEmpty) return;
    emit(
      state.copyWith(
        readIds: state.notifications.map((item) => item.id).toSet(),
      ),
    );
  }

  void clear() => emit(
    NotificationCenterState(permissionGranted: state.permissionGranted),
  );

  @override
  Future<void> close() async {
    await _receivedSub.cancel();
    await _openedSub.cancel();
    return super.close();
  }
}
