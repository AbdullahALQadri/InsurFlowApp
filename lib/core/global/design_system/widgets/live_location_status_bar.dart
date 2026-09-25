import 'package:flutter/material.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/global/design_system/widgets/location_status_bar.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';

/// Shows the device's real location status.
///
/// The badge used to be pinned to [GpsStatus.active], which claimed a
/// GPS fix the app did not have. It now follows
/// [LocationTrackingService] — including while the first fix is still
/// being taken, and when permission was refused.
class LiveLocationStatusBar extends StatefulWidget {
  const LiveLocationStatusBar({super.key, this.service});

  /// Injected in tests; otherwise the app-wide service.
  final LocationTrackingService? service;

  @override
  State<LiveLocationStatusBar> createState() => _LiveLocationStatusBarState();
}

class _LiveLocationStatusBarState extends State<LiveLocationStatusBar> {
  late final LocationTrackingService _service =
      widget.service ?? AppDependencies.instance.locationTrackingService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GpsStatus>(
      stream: _service.statusStream,
      // Whatever the service has already settled on, so the badge does
      // not flash back to "locating" on every rebuild.
      initialData: _service.currentStatus,
      builder: (context, snapshot) {
        return LocationStatusBar(
          status: snapshot.data ?? _service.currentStatus,
          lastUpdated: _service.lastUpdatedTime,
        );
      },
    );
  }
}
