import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';
import 'package:insurflow/features/claims/domain/entities/incident_coordinates.dart';

/// Maps the two claim shapes the mobile API returns.
///
/// Keys below are the exact ones the backend sends — verified against
/// the live `GET /claims` and `GET /claims/{id}` responses. No aliases:
/// if the contract changes, parsing should surface it rather than
/// silently fall back to a different key.
///
/// Both endpoints wrap the payload in `{success, message, data}`.
class ClaimModel {
  const ClaimModel({required this.entity});

  final Claim entity;

  /// Builds from a single claim object. [detailed] marks a payload that
  /// came from `GET /claims/{id}`, which carries the nested sections.
  factory ClaimModel.fromJson(dynamic raw, {required bool detailed}) {
    final json = JsonReader.asMap(raw) ?? const <String, dynamic>{};
    final statusRaw = JsonReader.string(json, ['status']);

    return ClaimModel(
      entity: Claim(
        id: JsonReader.string(json, ['id', '_id']) ?? '',
        claimNumber: JsonReader.string(json, ['claimNumber']),
        statusRaw: statusRaw,
        status: ClaimStatus.parse(statusRaw),
        summaryCustomerName: JsonReader.string(json, ['customerName']),
        summaryPlateNumber: JsonReader.string(json, ['initialPlateNumber']),
        summaryAssignedTo: _person(json['assignedTo']),
        fieldAdjuster: _person(json['fieldAdjuster']),
        incidentType: JsonReader.string(json, ['incidentType']),
        incidentLocation: JsonReader.string(json, ['incidentLocation']),
        incidentCoordinates: _coordinates(json['incidentCoordinates']),
        createdAt: JsonReader.date(json, ['createdAt']),
        updatedAt: JsonReader.date(json, ['updatedAt']),
        customer: _customer(json['customer']),
        vehicle: _vehicle(json['vehicle']),
        policy: _policy(json['policy']),
        assignment: _assignment(json['assignment']),
        accident: _accident(json['accident']),
        location: _location(json['location']),
        evidence: _evidence(json['evidence']),
        signature: _signature(json['signature']),
        timeline: _timeline(json['timeline']),
        createdBy: _person(json['createdBy']),
        decisionNotes: JsonReader.string(json, ['decisionNotes']),
        closedBy: _person(json['closedBy']),
        closedAt: JsonReader.date(json, ['closedAt']),
        closingNotes: JsonReader.string(json, ['closingNotes']),
        isDetailed: detailed,
      ),
    );
  }

  /// `GET /claims` -> `data` is a plain array of summary objects.
  static List<Claim> listFromResponse(dynamic body) {
    return JsonReader.list(body)
        .map((item) => ClaimModel.fromJson(item, detailed: false).entity)
        .where((claim) => claim.id.isNotEmpty)
        .toList();
  }

  /// `GET /claims/{id}` -> `data` is the full claim object.
  static Claim? fromResponse(dynamic body, {bool detailed = true}) {
    final entity = ClaimModel.fromJson(
      JsonReader.object(body),
      detailed: detailed,
    ).entity;
    return entity.id.isEmpty ? null : entity;
  }

  // --- Nested section parsers -------------------------------------------

  /// `{id, name}` on the list response; `{id, name, employeeCode}` on
  /// the detail response; `{..., role}` inside `timeline[].performedBy`.
  /// `uploadedBy` / `capturedBy` are a bare id string on the upload
  /// responses, so a plain string is accepted too.
  static ClaimAssignee? _person(Object? raw) {
    if (raw is String) {
      final id = raw.trim();
      return id.isEmpty ? null : ClaimAssignee(id: id);
    }
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final person = ClaimAssignee(
      id: JsonReader.string(json, ['id', '_id']),
      name: JsonReader.string(json, ['name']),
      employeeCode: JsonReader.string(json, ['employeeCode']),
      role: JsonReader.string(json, ['role']),
    );
    return person.hasValue ? person : null;
  }

  static ClaimCustomer? _customer(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final customer = ClaimCustomer(
      name: JsonReader.string(json, ['name']),
      phone: JsonReader.string(json, ['phone']),
    );
    return customer.hasValue ? customer : null;
  }

  static ClaimVehicleInfo? _vehicle(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final vehicle = ClaimVehicleInfo(
      plateNumber: JsonReader.string(json, ['plateNumber']),
      make: JsonReader.string(json, ['make']),
      model: JsonReader.string(json, ['model']),
      year: JsonReader.integer(json, ['year']),
      color: JsonReader.string(json, ['color']),
    );
    return vehicle.hasValue ? vehicle : null;
  }

  static ClaimPolicy? _policy(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final policy = ClaimPolicy(
      id: JsonReader.string(json, ['id', '_id']),
      policyNumber: JsonReader.string(json, ['policyNumber']),
      status: JsonReader.string(json, ['status']),
      startDate: JsonReader.date(json, ['startDate']),
      expiryDate: JsonReader.date(json, ['expiryDate']),
    );
    return policy.hasValue ? policy : null;
  }

  static ClaimAssignmentInfo? _assignment(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final assignment = ClaimAssignmentInfo(
      assignedTo: _person(json['assignedTo']),
      assignedBy: _person(json['assignedBy']),
      assignedAt: JsonReader.date(json, ['assignedAt']),
      priority: JsonReader.string(json, ['priority']),
      assignmentNotes: JsonReader.string(json, ['assignmentNotes']),
    );
    return assignment.hasValue ? assignment : null;
  }

  /// Returns null when every field is null, which is what the backend
  /// sends before the adjuster records the accident.
  static ClaimAccidentInfo? _accident(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final accident = ClaimAccidentInfo(
      accidentType: JsonReader.string(json, ['accidentType']),
      accidentDate: JsonReader.string(json, ['accidentDate']),
      accidentTime: JsonReader.string(json, ['accidentTime']),
      description: JsonReader.string(json, ['description']),
      damageDescription: JsonReader.string(json, ['damageDescription']),
    );
    return accident.hasValue ? accident : null;
  }

  static ClaimLocationInfo? _location(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final location = ClaimLocationInfo(
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      address: JsonReader.string(json, ['address']),
      capturedAt: JsonReader.date(json, ['capturedAt']),
    );
    return location.hasValue ? location : null;
  }

  static List<ClaimEvidenceItem> _evidence(Object? raw) {
    if (raw is! List) return const [];
    final items = <ClaimEvidenceItem>[];
    for (final entry in raw) {
      final json = JsonReader.asMap(entry);
      if (json == null) continue;
      items.add(
        ClaimEvidenceItem(
          imageType: JsonReader.string(json, ['imageType']),
          url: JsonReader.string(json, ['url']),
          uploadedBy: _person(json['uploadedBy']),
          uploadedAt: JsonReader.date(json, ['uploadedAt']),
        ),
      );
    }
    return items;
  }

  static ClaimSignatureInfo? _signature(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final signature = ClaimSignatureInfo(
      url: JsonReader.string(json, ['url']),
      capturedBy: _person(json['capturedBy']),
      capturedAt: JsonReader.date(json, ['capturedAt']),
    );
    return signature.hasImage || signature.capturedAt != null
        ? signature
        : null;
  }

  /// Oldest-first, exactly as the backend orders it.
  static List<ClaimTimelineEntry> _timeline(Object? raw) {
    if (raw is! List) return const [];
    final entries = <ClaimTimelineEntry>[];
    for (final entry in raw) {
      final json = JsonReader.asMap(entry);
      if (json == null) continue;
      entries.add(
        ClaimTimelineEntry(
          action: JsonReader.string(json, ['action']),
          previousStatus: JsonReader.string(json, ['previousStatus']),
          newStatus: JsonReader.string(json, ['newStatus']),
          notes: JsonReader.string(json, ['notes']),
          performedBy: _person(json['performedBy']),
          role: JsonReader.string(json, ['role']),
          timestamp: JsonReader.date(json, ['timestamp']),
        ),
      );
    }
    return entries;
  }

  static IncidentCoordinates? _coordinates(Object? raw) {
    final json = JsonReader.asMap(raw);
    if (json == null) return null;
    final latitude = _double(json['latitude']);
    final longitude = _double(json['longitude']);
    if (latitude == null || longitude == null) return null;
    return IncidentCoordinates(
      latitude: latitude,
      longitude: longitude,
      capturedAt: JsonReader.date(json, ['capturedAt']),
    );
  }

  static double? _double(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
