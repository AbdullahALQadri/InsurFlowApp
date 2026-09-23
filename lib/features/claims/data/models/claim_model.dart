import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';
import 'package:insurflow/features/claims/domain/entities/incident_coordinates.dart';

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
        // NOTE: `assignedBy` is a different concept from `assignedTo`.
        // It is not part of the current GET /claims response, so it
        // stays null unless another confirmed contract provides it.
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
        // Nested objects from GET /claims. Null-safe: the backend may
        // send `"incidentCoordinates": null`.
        assignedTo: _readAssignee(json, 'assignedTo'),
        fieldAdjuster: _readAssignee(json, 'fieldAdjuster'),
        incidentCoordinates: _readCoordinates(
          json['incidentCoordinates'] ?? json['incident_coordinates'],
        ),
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

  /// Reads the nested assignee objects (`assignedTo`, `fieldAdjuster`).
  /// Returns null when the key is absent or the object carries no data.
  static ClaimAssignee? _readAssignee(Map<String, dynamic> json, String key) {
    final nested = JsonReader.asMap(json[key]);
    if (nested == null) return null;
    final id = JsonReader.string(nested, ['_id', 'id']);
    final name = JsonReader.string(nested, ['name', 'fullName']);
    if (id == null && name == null) return null;
    return ClaimAssignee(id: id, name: name);
  }

  /// Reads the nested `incidentCoordinates` object. Returns null when
  /// the backend sends `"incidentCoordinates": null` or a partial fix.
  static IncidentCoordinates? _readCoordinates(Object? raw) {
    final nested = JsonReader.asMap(raw);
    if (nested == null) return null;
    final latitude = _readDouble(nested['latitude']);
    final longitude = _readDouble(nested['longitude']);
    if (latitude == null || longitude == null) return null;
    return IncidentCoordinates(
      latitude: latitude,
      longitude: longitude,
      capturedAt: JsonReader.date(nested, ['capturedAt', 'captured_at']),
    );
  }

  static double? _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
