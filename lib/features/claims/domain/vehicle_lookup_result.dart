import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';

/// Result of `GET /vehicles/lookup?plateNumber=...`.
///
/// The backend returns three sibling objects:
///
/// ```
/// data: {
///   vehicle:  {id, plateNumber, make, model, year, color},
///   customer: {id, fullName, phone},
///   policy:   {id, policyNumber, status, startDate, expiryDate}
/// }
/// ```
///
/// Note `customer.fullName` here, against `customer.name` on
/// `GET /claims/{id}` — the two endpoints genuinely differ.
///
/// The three `id` values are the payload of the follow-up
/// `PUT /claims/{id}/vehicle`, which requires `vehicleId`, `policyId`
/// and `customerId`, so they are kept rather than discarded.
///
/// An unknown plate returns 404 `VEHICLE_NOT_FOUND`; that surfaces as a
/// failure, never as an empty-but-successful result.
class VehicleLookupResult {
  const VehicleLookupResult({
    required this.claimId,
    required this.licensePlate,
    this.vehicleId,
    this.makeModel,
    this.year,
    this.color,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.policyId,
    this.policyNumber,
    this.policyStatus,
    this.policyStart,
    this.policyEnd,
  });

  final String claimId;

  /// Echoed from `vehicle.plateNumber`, falling back to the plate the
  /// adjuster entered when the backend omits it.
  final String licensePlate;

  final String? vehicleId;
  final String? makeModel;
  final int? year;
  final String? color;

  final String? customerId;
  final String? customerName;
  final String? customerPhone;

  final String? policyId;
  final String? policyNumber;

  /// Raw backend value, e.g. `ACTIVE`.
  final String? policyStatus;
  final DateTime? policyStart;
  final DateTime? policyEnd;

  bool get hasVehicle => (makeModel?.trim().isNotEmpty ?? false);

  bool get hasCustomer => (customerName?.trim().isNotEmpty ?? false);

  bool get hasPolicy => (policyNumber?.trim().isNotEmpty ?? false);

  bool get isPolicyActive => policyStatus?.trim().toUpperCase() == 'ACTIVE';

  String? get policyStatusLabel => humanizeEnum(policyStatus);

  /// True when all three ids needed by `PUT /claims/{id}/vehicle` are
  /// present. Without them the claim cannot be linked.
  bool get canLinkToClaim =>
      (vehicleId?.trim().isNotEmpty ?? false) &&
      (policyId?.trim().isNotEmpty ?? false) &&
      (customerId?.trim().isNotEmpty ?? false);

  /// Nothing has been looked up yet: the plate is all that is known.
  /// Every other field stays null so the UI renders its "not available"
  /// state instead of a fabricated vehicle, customer or policy.
  factory VehicleLookupResult.empty({
    required String claimId,
    String plateNumber = '',
  }) {
    return VehicleLookupResult(
      claimId: claimId,
      licensePlate: plateNumber.trim(),
    );
  }

  factory VehicleLookupResult.fromResponse(
    dynamic body, {
    required String claimId,
    required String plateNumber,
  }) {
    final json = JsonReader.object(body) ?? const <String, dynamic>{};
    final vehicle = JsonReader.asMap(json['vehicle']);
    final customer = JsonReader.asMap(json['customer']);
    final policy = JsonReader.asMap(json['policy']);

    String? makeModel;
    if (vehicle != null) {
      final make = JsonReader.string(vehicle, ['make']);
      final model = JsonReader.string(vehicle, ['model']);
      final parts = [
        if (make != null && make.isNotEmpty) make,
        if (model != null && model.isNotEmpty) model,
      ];
      if (parts.isNotEmpty) makeModel = parts.join(' ');
    }

    return VehicleLookupResult(
      claimId: claimId,
      licensePlate:
          (vehicle == null
              ? null
              : JsonReader.string(vehicle, ['plateNumber'])) ??
          plateNumber.trim(),
      vehicleId: vehicle == null
          ? null
          : JsonReader.string(vehicle, ['id', '_id']),
      makeModel: makeModel,
      year: vehicle == null ? null : JsonReader.integer(vehicle, ['year']),
      color: vehicle == null ? null : JsonReader.string(vehicle, ['color']),
      customerId: customer == null
          ? null
          : JsonReader.string(customer, ['id', '_id']),
      customerName: customer == null
          ? null
          : JsonReader.string(customer, ['fullName']),
      customerPhone: customer == null
          ? null
          : JsonReader.string(customer, ['phone']),
      policyId: policy == null
          ? null
          : JsonReader.string(policy, ['id', '_id']),
      policyNumber: policy == null
          ? null
          : JsonReader.string(policy, ['policyNumber']),
      policyStatus: policy == null
          ? null
          : JsonReader.string(policy, ['status']),
      policyStart: policy == null
          ? null
          : JsonReader.date(policy, ['startDate']),
      policyEnd: policy == null
          ? null
          : JsonReader.date(policy, ['expiryDate']),
    );
  }
}
