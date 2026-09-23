/// GPS fix captured for a claim's incident location.
///
/// Maps the nested `incidentCoordinates` object returned by
/// `GET /claims`. When the backend sends `"incidentCoordinates": null`
/// the claim simply has no coordinates — nothing is fabricated.
class IncidentCoordinates {
  const IncidentCoordinates({
    required this.latitude,
    required this.longitude,
    this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime? capturedAt;

  String get label =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
