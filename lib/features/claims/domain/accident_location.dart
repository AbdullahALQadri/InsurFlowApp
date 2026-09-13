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

  static const demoStreet = 'Al-Quds Street';
  static const demoCity = 'Tulkarm';
  static const demoLatitude = 32.31;
  static const demoLongitude = 35.03;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  factory AccidentLocation.demo({
    required String claimId,
    DateTime? capturedAt,
  }) {
    return AccidentLocation(
      claimId: claimId,
      street: demoStreet,
      city: demoCity,
      latitude: demoLatitude,
      longitude: demoLongitude,
      capturedAt: capturedAt ?? DateTime(2026, 8, 24, 16, 42),
    );
  }
}
