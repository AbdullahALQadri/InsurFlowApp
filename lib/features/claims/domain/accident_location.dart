import 'package:insurflow/core/constants/location_method.dart';

class AccidentLocation {
  const AccidentLocation({
    required this.claimId,
    required this.street,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.method = LocationMethod.gps,
  });

  final String claimId;
  final String street;
  final String city;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final LocationMethod method;

  /// No fix has been acquired yet: street/city are empty and the
  /// coordinates are the null island sentinel (see [hasCoordinates]).
  bool get hasCoordinates =>
      !(latitude == 0 && longitude == 0) || street.trim().isNotEmpty;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// TODO(gps): No device location plugin is installed yet, and
  /// PUT /claims/{id}/location must receive a real GPS fix. This
  /// placeholder carries no fabricated address or coordinates — the
  /// UI shows "not available" until a real fix is captured.
  factory AccidentLocation.pending({required String claimId}) {
    return AccidentLocation(
      claimId: claimId,
      street: '',
      city: '',
      latitude: 0,
      longitude: 0,
      capturedAt: DateTime.now(),
    );
  }
}
