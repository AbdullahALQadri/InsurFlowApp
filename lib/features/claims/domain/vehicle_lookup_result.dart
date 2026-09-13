import 'package:insurflow/core/network/json_reader.dart';

enum PolicyStatus { active, unknown }

class VehicleLookupResult {
  const VehicleLookupResult({
    required this.claimId,
    required this.makeModel,
    required this.year,
    required this.colorKey,
    required this.licensePlate,
    required this.customerName,
    required this.customerPhone,
    required this.policyNumber,
    required this.policyStatus,
    required this.policyStart,
    required this.policyEnd,
  });

  final String claimId;
  final String makeModel;
  final int year;
  final String colorKey;
  final String licensePlate;
  final String customerName;
  final String customerPhone;
  final String policyNumber;
  final PolicyStatus policyStatus;
  final DateTime policyStart;
  final DateTime policyEnd;

  bool get hasVehicle => makeModel.trim().isNotEmpty;
  bool get hasCustomer => customerName.trim().isNotEmpty;
  bool get hasPolicy => policyNumber.trim().isNotEmpty;

  static const demoPlateNumber = 'ABC-1234';
  static const demoPolicyNumber = 'POL-102938';

  factory VehicleLookupResult.demo({
    required String claimId,
    String? plateNumber,
  }) {
    final plate = plateNumber?.trim();
    return VehicleLookupResult(
      claimId: claimId,
      makeModel: 'Toyota Corolla',
      year: 2022,
      colorKey: 'white',
      licensePlate: (plate != null && plate.isNotEmpty)
          ? plate
          : demoPlateNumber,
      customerName: 'Ahmed Ali',
      customerPhone: '059xxxxxxx',
      policyNumber: demoPolicyNumber,
      policyStatus: PolicyStatus.active,
      policyStart: DateTime(2026, 1, 1),
      policyEnd: DateTime(2026, 12, 31),
    );
  }

  factory VehicleLookupResult.fromResponse(
    dynamic body, {
    required String claimId,
    required String plateNumber,
  }) {
    final json = JsonReader.object(body) ?? JsonReader.asMap(body) ?? {};
    final vehicle = JsonReader.nested(json, ['vehicle']) ?? json;
    final customer = JsonReader.nested(json, ['customer']) ?? json;
    final policy = JsonReader.nested(json, ['policy']) ?? json;
    final make = JsonReader.string(vehicle, ['make', 'vehicleMake', 'brand']);
    final model = JsonReader.string(vehicle, ['model', 'vehicleModel']);
    final makeModel = [
      if (make != null && make.isNotEmpty) make,
      if (model != null && model.isNotEmpty) model,
    ].join(' ');
    final combinedMakeModel = makeModel.isNotEmpty
        ? makeModel
        : (JsonReader.string(vehicle, ['makeModel', 'name']) ?? '');
    final plate =
        JsonReader.string(vehicle, [
          'plateNumber',
          'licensePlate',
          'initialPlateNumber',
          'plate',
        ]) ??
        JsonReader.string(json, ['plateNumber', 'licensePlate', 'plate']) ??
        plateNumber;
    final statusRaw = JsonReader.string(policy, ['status', 'policyStatus']);

    return VehicleLookupResult(
      claimId: claimId,
      makeModel: combinedMakeModel,
      year: JsonReader.integer(vehicle, ['year', 'vehicleYear']) ?? 0,
      colorKey:
          JsonReader.string(vehicle, ['color', 'colour', 'colorKey']) ?? '',
      licensePlate: plate,
      customerName:
          JsonReader.string(customer, ['name', 'customerName', 'fullName']) ??
          '',
      customerPhone:
          JsonReader.string(customer, [
            'phone',
            'customerPhone',
            'mobile',
            'phoneNumber',
          ]) ??
          '',
      policyNumber:
          JsonReader.string(policy, ['policyNumber', 'number', 'policyNo']) ??
          '',
      policyStatus: _parsePolicyStatus(statusRaw),
      policyStart:
          JsonReader.date(policy, ['startDate', 'policyStart', 'start']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      policyEnd:
          JsonReader.date(policy, [
            'expiryDate',
            'endDate',
            'policyEnd',
            'expiry',
          ]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static PolicyStatus _parsePolicyStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty) return PolicyStatus.unknown;
    final normalized = raw.trim().toUpperCase().replaceAll(' ', '_');
    if (normalized == 'ACTIVE') return PolicyStatus.active;
    return PolicyStatus.unknown;
  }
}
