import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_location.dart';

enum GpsStatus {
  active,
  weakGps,
  disabled,
  permissionDenied,
  waitingConnection;

  String get label {
    switch (this) {
      case GpsStatus.active:
        return 'Active';
      case GpsStatus.weakGps:
        return 'Weak GPS';
      case GpsStatus.disabled:
        return 'Location Disabled';
      case GpsStatus.permissionDenied:
        return 'Permission Denied';
      case GpsStatus.waitingConnection:
        return 'Waiting Connection';
    }
  }

  String labelAr(bool isArabic) {
    if (!isArabic) return label;
    switch (this) {
      case GpsStatus.active:
        return 'الموقع نشط';
      case GpsStatus.weakGps:
        return 'تغطية ضعيفة';
      case GpsStatus.disabled:
        return 'الموقع معطل';
      case GpsStatus.permissionDenied:
        return 'الصلاحية مرفوضة';
      case GpsStatus.waitingConnection:
        return 'في انتظار الاتصال';
    }
  }
}

/// Periodic claim-location reporter.
///
/// TODO(gps): No device location plugin is installed yet. This service
/// must NOT transmit fabricated coordinates to PUT /claims/{id}/location,
/// so transmissions are paused until a real GPS source is wired through
/// [UpdateClaimLocationUseCase]. Do not invent a position or address.
class LocationTrackingService {
  LocationTrackingService({
    UpdateClaimLocationUseCase? updateClaimLocationUseCase,
  }) : _updateClaimLocationUseCase = updateClaimLocationUseCase;

  final UpdateClaimLocationUseCase? _updateClaimLocationUseCase;

  final _statusController = StreamController<GpsStatus>.broadcast();
  final _lastUpdateController = StreamController<DateTime>.broadcast();

  GpsStatus _currentStatus = GpsStatus.disabled;
  DateTime? _lastUpdatedTime;
  String? _activeClaimId;
  Timer? _pollingTimer;

  GpsStatus get currentStatus => _currentStatus;
  DateTime? get lastUpdatedTime => _lastUpdatedTime;
  Stream<GpsStatus> get statusStream => _statusController.stream;
  Stream<DateTime> get lastUpdateStream => _lastUpdateController.stream;

  void startTracking({required String claimId}) {
    _activeClaimId = claimId;
    // No location source yet — report the honest state instead of a
    // simulated "Active" GPS fix.
    _currentStatus = GpsStatus.disabled;
    _statusController.add(_currentStatus);

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _transmitLocationUpdate();
    });

    _transmitLocationUpdate();
  }

  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeClaimId = null;
  }

  Future<void> _transmitLocationUpdate() async {
    if (_activeClaimId == null || _updateClaimLocationUseCase == null) return;

    // TODO(gps): Capture a real device fix first, then send it here:
    // await _updateClaimLocationUseCase!(
    //   claimId: _activeClaimId!,
    //   latitude: fix.latitude,
    //   longitude: fix.longitude,
    //   address: resolvedAddress,
    //   capturedAt: fix.time,
    // );
    // Never send hardcoded or simulated coordinates to the backend.
    _currentStatus = GpsStatus.disabled;
    _statusController.add(_currentStatus);
  }

  void dispose() {
    _pollingTimer?.cancel();
    _statusController.close();
    _lastUpdateController.close();
  }
}
