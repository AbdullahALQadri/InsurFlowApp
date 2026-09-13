import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

class ClaimModel {
  const ClaimModel({required this.entity});

  final Claim entity;

  factory ClaimModel.fromJson(dynamic raw) {
    final json = JsonReader.object(raw) ?? JsonReader.asMap(raw) ?? {};
    final id = JsonReader.string(json, ['_id', 'id', 'claimId']) ?? '';
    final statusRaw = JsonReader.string(json, ['status', 'claimStatus']);

    return ClaimModel(
      entity: Claim(
        id: id,
        claimNumber: JsonReader.string(json, [
          'claimNumber',
          'claimNo',
          'number',
        ]),
        statusRaw: statusRaw,
        status: ClaimStatus.parse(statusRaw),
        customerName: JsonReader.string(json, [
          'customerName',
          'customer_name',
        ]),
        customerPhone: JsonReader.string(json, [
          'customerPhone',
          'customer_phone',
        ]),
        initialPlateNumber: JsonReader.string(json, [
          'initialPlateNumber',
          'plateNumber',
          'licensePlate',
        ]),
        incidentType: JsonReader.string(json, [
          'incidentType',
          'incident_type',
        ]),
        vehicleMake: JsonReader.string(
          JsonReader.nested(json, ['vehicle']) ?? json,
          ['vehicleMake', 'make', 'brand'],
        ),
        vehicleModel: JsonReader.string(
          JsonReader.nested(json, ['vehicle']) ?? json,
          ['vehicleModel', 'model'],
        ),
        incidentLocation: JsonReader.string(json, [
          'incidentLocation',
          'incident_location',
          'location',
          'address',
        ]),
        adjusterId: JsonReader.string(json, ['adjusterId', 'adjuster_id']),
        priority: JsonReader.string(json, ['priority']),
        notes: JsonReader.string(json, ['notes']),
        assignedBy: JsonReader.string(json, [
          'assignedBy',
          'assigned_by',
          'assignedByName',
        ]),
        assignedAt: JsonReader.date(json, [
          'assignedAt',
          'assigned_at',
          'assignedDate',
        ]),
        createdAt: JsonReader.date(json, ['createdAt', 'created_at']),
        updatedAt: JsonReader.date(json, [
          'updatedAt',
          'updated_at',
          'lastUpdated',
        ]),
      ),
    );
  }

  static List<Claim> listFromResponse(dynamic body) {
    return JsonReader.list(body)
        .map(ClaimModel.fromJson)
        .map((model) => model.entity)
        .where((claim) => claim.id.isNotEmpty)
        .toList();
  }

  static Claim? fromResponse(dynamic body) {
    final entity = ClaimModel.fromJson(body).entity;
    if (entity.id.isEmpty) return null;
    return entity;
  }
}
