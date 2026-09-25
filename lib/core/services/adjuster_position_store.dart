import 'package:insurflow/core/services/device_location_service.dart';

/// Holds the adjuster's most recent device fix for request headers.
///
/// The backend reads the adjuster's current position from the
/// `X-Latitude` / `X-Longitude` headers on ordinary requests — there is
/// no endpoint that reports it, and `PUT /claims/{id}/location` records
/// the *claim's* location, which is a different thing.
///
/// Nothing is stored until the device actually produces a fix, so the
/// headers are absent rather than carrying an invented position.
class AdjusterPositionStore {
  DeviceLocation? _latest;

  DeviceLocation? get latest => _latest;

  void record(DeviceLocation fix) => _latest = fix;

  /// Dropped on sign-out: the next user must not inherit this one's
  /// position.
  void clear() => _latest = null;

  /// The headers for the current fix, or an empty map when there is
  /// none. String values because headers are text on the wire.
  Map<String, String> get headers {
    final fix = _latest;
    if (fix == null) return const {};
    return {
      'X-Latitude': fix.latitude.toString(),
      'X-Longitude': fix.longitude.toString(),
    };
  }
}
