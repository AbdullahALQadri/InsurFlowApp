/// A latitude/longitude pair from the backend that is safe to hand to a
/// map.
///
/// The claim payload carries coordinates in two separate places and
/// both can be absent:
///
/// * `incidentCoordinates {latitude, longitude, capturedAt}` — where the
///   incident was reported.
/// * `location {latitude, longitude, address, capturedAt}` — the fix the
///   field adjuster captured, all-null until
///   `PUT /claims/{id}/location` has run.
///
/// [tryCreate] returns null unless both values are present and within
/// real geographic range, so a map is never initialised with null, NaN,
/// infinite or out-of-range coordinates. Nothing is substituted for a
/// missing value — callers render an empty state instead.
class ClaimMapPoint {
  const ClaimMapPoint._({
    required this.latitude,
    required this.longitude,
    this.address,
    this.capturedAt,
  });

  final double latitude;
  final double longitude;

  /// `location.address` when the backend sent one. Never derived from
  /// the coordinates and never geocoded locally.
  final String? address;

  final DateTime? capturedAt;

  /// Builds a point only from coordinates that can actually be mapped.
  static ClaimMapPoint? tryCreate({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? capturedAt,
  }) {
    if (latitude == null || longitude == null) return null;
    if (!latitude.isFinite || !longitude.isFinite) return null;
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;

    final trimmedAddress = address?.trim();
    return ClaimMapPoint._(
      latitude: latitude,
      longitude: longitude,
      address: (trimmedAddress == null || trimmedAddress.isEmpty)
          ? null
          : trimmedAddress,
      capturedAt: capturedAt,
    );
  }

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Distinguishes one claim's point from another so a map widget can
  /// be keyed on it and rebuilt only when the coordinates really change.
  String get mapKey => '$latitude,$longitude';

  @override
  bool operator ==(Object other) =>
      other is ClaimMapPoint &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.address == address &&
      other.capturedAt == capturedAt;

  @override
  int get hashCode => Object.hash(latitude, longitude, address, capturedAt);
}
