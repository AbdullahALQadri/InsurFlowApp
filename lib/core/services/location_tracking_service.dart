import 'dart:async';

import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/services/adjuster_position_store.dart';
import 'package:insurflow/core/services/device_location_service.dart';

/// What the device's location subsystem is currently doing.
///
/// The copy for each value lives in `AppStrings`, not here: this is a
/// service, and a service should not decide how anything reads.
enum GpsStatus {
  active,
  weakGps,
  disabled,
  permissionDenied,
  waitingConnection,
}

/// Keeps the adjuster's current position fresh for request headers.
///
/// The backend takes the adjuster's position from `X-Latitude` /
/// `X-Longitude` on ordinary requests, so this service never issues a
/// request of its own — it refreshes [AdjusterPositionStore] and
/// reports an honest [GpsStatus]. A fix is only recorded when the
/// device produces one; a failure clears nothing and invents nothing,
/// it just changes the status.
class LocationTrackingService {
  LocationTrackingService({
    required DeviceLocationService locationService,
    required AdjusterPositionStore positionStore,
    Duration interval = const Duration(minutes: 2),
  }) : _locationService = locationService,
       _positionStore = positionStore,
       _interval = interval;

  final DeviceLocationService _locationService;
  final AdjusterPositionStore _positionStore;
  final Duration _interval;

  final _statusController = StreamController<GpsStatus>.broadcast();
  final _lastUpdateController = StreamController<DateTime>.broadcast();

  /// Nothing has been attempted yet, so the honest answer is that the
  /// app is still waiting — not that GPS is off.
  GpsStatus _currentStatus = GpsStatus.waitingConnection;
  DateTime? _lastUpdatedTime;
  Timer? _pollingTimer;
  var _isRefreshing = false;

  GpsStatus get currentStatus => _currentStatus;
  DateTime? get lastUpdatedTime => _lastUpdatedTime;
  Stream<GpsStatus> get statusStream => _statusController.stream;
  Stream<DateTime> get lastUpdateStream => _lastUpdateController.stream;

  /// Begins refreshing the position. Safe to call more than once; the
  /// previous timer is replaced rather than stacked.
  void start() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_interval, (_) => refresh());
    refresh();
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Takes one fix now. Overlapping calls are ignored, since a fix can
  /// take longer than the polling interval on a weak signal.
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final result = await _locationService.currentLocation();
      result.fold(_onFailure, _onFix);
    } finally {
      _isRefreshing = false;
    }
  }

  void _onFix(DeviceLocation fix) {
    _positionStore.record(fix);
    _lastUpdatedTime = fix.capturedAt;
    if (!_lastUpdateController.isClosed) {
      _lastUpdateController.add(fix.capturedAt);
    }
    // `accuracy` is metres of horizontal error, so a large number is a
    // poor fix. It is still recorded — a rough position beats none.
    final accuracy = fix.accuracy;
    _emit(
      accuracy != null && accuracy > _weakAccuracyMetres
          ? GpsStatus.weakGps
          : GpsStatus.active,
    );
  }

  void _onFailure(Failure failure) {
    _emit(switch (failure) {
      LocationServiceDisabledFailure() => GpsStatus.disabled,
      LocationPermissionDeniedFailure() => GpsStatus.permissionDenied,
      LocationPermissionDeniedForeverFailure() => GpsStatus.permissionDenied,
      _ => GpsStatus.waitingConnection,
    });
  }

  void _emit(GpsStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  /// Above this many metres of error the fix is worth showing but not
  /// worth calling a good one.
  static const _weakAccuracyMetres = 100.0;

  void dispose() {
    _pollingTimer?.cancel();
    _statusController.close();
    _lastUpdateController.close();
  }
}
