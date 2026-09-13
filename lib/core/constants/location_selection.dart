
class LocationSelection {
  String? method;

  double? latitude;
  double? longitude;
  DateTime? capturedAt;

  String? governorate;
  String? region;
  String? streetNeighborhood;
  String? landmark;

  bool get isManual => method != null && method!.contains('يدوي');
  bool get isGps => method != null && method!.contains('GPS');
  bool get wasCapturedByGps => capturedAt != null;

  bool get hasBasics =>
      governorate != null && region != null && streetNeighborhood != null;


  void resetAddress() {
    latitude = null;
    longitude = null;
    capturedAt = null;
    governorate = null;
    region = null;
    streetNeighborhood = null;
  }
}
