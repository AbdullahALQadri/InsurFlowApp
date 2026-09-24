import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';
import 'package:insurflow/features/claims/domain/entities/claim_map_point.dart';
import 'package:insurflow/features/claims/domain/entities/incident_coordinates.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';

/// A claim as returned by the mobile endpoints.
///
/// Two shapes feed this entity and both are represented faithfully:
///
/// * `GET /claims` — a flat summary: `id, claimNumber, status,
///   customerName, initialPlateNumber, createdAt, assignedTo,
///   fieldAdjuster, incidentCoordinates`.
/// * `GET /claims/{id}` — the same claim with nested `customer`,
///   `vehicle`, `policy`, `assignment`, `accident`, `location`,
///   `evidence[]`, `signature`, `timeline[]`, `createdBy` and the
///   closure fields.
///
/// Anything the backend did not send stays null. [isDetailed]
/// distinguishes a summary from a fully loaded claim so screens can
/// tell "not captured yet" apart from "not loaded yet".
class Claim {
  const Claim({
    required this.id,
    required this.status,
    this.claimNumber,
    this.statusRaw,
    this.summaryCustomerName,
    this.summaryPlateNumber,
    this.summaryAssignedTo,
    this.fieldAdjuster,
    this.incidentType,
    this.incidentLocation,
    this.incidentCoordinates,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.vehicle,
    this.policy,
    this.assignment,
    this.accident,
    this.location,
    this.evidence = const [],
    this.signature,
    this.timeline = const [],
    this.createdBy,
    this.decisionNotes,
    this.closedBy,
    this.closedAt,
    this.closingNotes,
    this.isDetailed = false,
  });

  final String id;
  final ClaimStatus status;
  final String? claimNumber;

  /// Raw backend status string, kept so an unmapped value is never lost.
  final String? statusRaw;

  /// `customerName` from the list response. On the detail response the
  /// name lives in [customer] instead — read [customerName].
  final String? summaryCustomerName;

  /// `initialPlateNumber` from the list response. The detail response
  /// carries the plate in [vehicle] — read [plateNumber].
  final String? summaryPlateNumber;

  /// Root-level `assignedTo` from the list response. The detail
  /// response nests it under `assignment` — read [assignedTo].
  final ClaimAssignee? summaryAssignedTo;

  /// Root-level `fieldAdjuster`, list response only.
  final ClaimAssignee? fieldAdjuster;

  final String? incidentType;
  final String? incidentLocation;

  /// Coordinates filed with the claim, distinct from the adjuster's
  /// captured [location].
  final IncidentCoordinates? incidentCoordinates;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ClaimCustomer? customer;
  final ClaimVehicleInfo? vehicle;
  final ClaimPolicy? policy;
  final ClaimAssignmentInfo? assignment;
  final ClaimAccidentInfo? accident;
  final ClaimLocationInfo? location;
  final List<ClaimEvidenceItem> evidence;
  final ClaimSignatureInfo? signature;
  final List<ClaimTimelineEntry> timeline;
  final ClaimAssignee? createdBy;

  final String? decisionNotes;
  final ClaimAssignee? closedBy;
  final DateTime? closedAt;
  final String? closingNotes;

  /// True when built from `GET /claims/{id}`.
  final bool isDetailed;

  // --- Derived accessors -------------------------------------------------

  String get displayNumber =>
      claimNumber?.trim().isNotEmpty == true ? claimNumber!.trim() : id;

  /// `customer.name` on the detail response, `customerName` on the list.
  String? get customerName =>
      _firstNonEmpty([customer?.name, summaryCustomerName]);

  String? get customerPhone => _firstNonEmpty([customer?.phone]);

  /// `vehicle.plateNumber` on the detail response, `initialPlateNumber`
  /// on the list.
  String? get plateNumber =>
      _firstNonEmpty([vehicle?.plateNumber, summaryPlateNumber]);

  String? get vehicleMakeModel => vehicle?.makeModel;

  /// The person the claim is assigned to, from whichever shape was
  /// loaded. [fieldAdjuster] is the list response's parallel field.
  ClaimAssignee? get assignedTo {
    final nested = assignment?.assignedTo;
    if (nested?.hasValue ?? false) return nested;
    if (summaryAssignedTo?.hasValue ?? false) return summaryAssignedTo;
    return fieldAdjuster?.hasValue ?? false ? fieldAdjuster : null;
  }

  ClaimAssignee? get assignedBy {
    final person = assignment?.assignedBy;
    return (person?.hasValue ?? false) ? person : null;
  }

  String? get priority => _firstNonEmpty([assignment?.priority]);

  DateTime? get assignedAt => assignment?.assignedAt;

  /// Note attached when the claim was assigned.
  String? get assignmentNotes => _firstNonEmpty([assignment?.assignmentNotes]);

  /// The note the reviewer attached when sending the claim back. Read
  /// from the newest `timeline` entry whose `newStatus` is
  /// `CORRECTION_REQUIRED`, since the backend records it nowhere else.
  String? get correctionNote {
    for (final entry in timeline.reversed) {
      if (entry.newStatus?.trim().toUpperCase() != 'CORRECTION_REQUIRED') {
        continue;
      }
      final notes = entry.notes?.trim();
      if (notes != null && notes.isNotEmpty) return notes;
    }
    return _firstNonEmpty([decisionNotes]);
  }

  String? get incidentTypeLabel => humanizeEnum(incidentType);

  /// Mappable point for `incidentCoordinates` — where the incident was
  /// reported. Null when the backend sent no usable coordinates.
  ClaimMapPoint? get incidentMapPoint => ClaimMapPoint.tryCreate(
    latitude: incidentCoordinates?.latitude,
    longitude: incidentCoordinates?.longitude,
    // `incidentLocation` is a free-text description filed with the
    // claim, and it is the only address the backend attaches to this
    // position.
    address: incidentLocation,
    capturedAt: incidentCoordinates?.capturedAt,
  );

  /// Mappable point for the adjuster's captured `location`. Null until
  /// `PUT /claims/{id}/location` has recorded a fix.
  ClaimMapPoint? get capturedMapPoint => ClaimMapPoint.tryCreate(
    latitude: location?.latitude,
    longitude: location?.longitude,
    address: location?.address,
    capturedAt: location?.capturedAt,
  );

  /// The point that best represents where this claim is: the adjuster's
  /// verified fix when one exists, otherwise the reported position.
  ClaimMapPoint? get primaryMapPoint => capturedMapPoint ?? incidentMapPoint;

  bool get hasMappableLocation => primaryMapPoint != null;

  DateTime get lastUpdated =>
      updatedAt ?? assignedAt ?? createdAt ?? DateTime.now();

  /// Evidence entries that actually carry a URL.
  List<ClaimEvidenceItem> get evidencePhotos =>
      evidence.where((item) => item.hasImage).toList();

  /// Timeline newest-first, the order screens read it in.
  List<ClaimTimelineEntry> get timelineLatestFirst =>
      timeline.reversed.toList();

  ClaimPreview toPreview() {
    return ClaimPreview(
      id: id,
      claimNumber: claimNumber,
      vehicle: vehicleMakeModel ?? '',
      licensePlate: plateNumber ?? '',
      location: incidentLocation ?? '',
      status: status,
      lastUpdated: lastUpdated,
      priority: priority,
      customerName: customerName,
      completedSteps: InspectionProgress.forClaim(this).completedCount,
      totalSteps: InspectionProgress.totalCount,
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  Claim copyWith({
    String? id,
    ClaimStatus? status,
    String? claimNumber,
    String? statusRaw,
    String? summaryCustomerName,
    String? summaryPlateNumber,
    ClaimAssignee? summaryAssignedTo,
    ClaimAssignee? fieldAdjuster,
    String? incidentType,
    String? incidentLocation,
    IncidentCoordinates? incidentCoordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClaimCustomer? customer,
    ClaimVehicleInfo? vehicle,
    ClaimPolicy? policy,
    ClaimAssignmentInfo? assignment,
    ClaimAccidentInfo? accident,
    ClaimLocationInfo? location,
    List<ClaimEvidenceItem>? evidence,
    ClaimSignatureInfo? signature,
    List<ClaimTimelineEntry>? timeline,
    ClaimAssignee? createdBy,
    String? decisionNotes,
    ClaimAssignee? closedBy,
    DateTime? closedAt,
    String? closingNotes,
    bool? isDetailed,
  }) {
    return Claim(
      id: id ?? this.id,
      status: status ?? this.status,
      claimNumber: claimNumber ?? this.claimNumber,
      statusRaw: statusRaw ?? this.statusRaw,
      summaryCustomerName: summaryCustomerName ?? this.summaryCustomerName,
      summaryPlateNumber: summaryPlateNumber ?? this.summaryPlateNumber,
      summaryAssignedTo: summaryAssignedTo ?? this.summaryAssignedTo,
      fieldAdjuster: fieldAdjuster ?? this.fieldAdjuster,
      incidentType: incidentType ?? this.incidentType,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      incidentCoordinates: incidentCoordinates ?? this.incidentCoordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      vehicle: vehicle ?? this.vehicle,
      policy: policy ?? this.policy,
      assignment: assignment ?? this.assignment,
      accident: accident ?? this.accident,
      location: location ?? this.location,
      evidence: evidence ?? this.evidence,
      signature: signature ?? this.signature,
      timeline: timeline ?? this.timeline,
      createdBy: createdBy ?? this.createdBy,
      decisionNotes: decisionNotes ?? this.decisionNotes,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
      closingNotes: closingNotes ?? this.closingNotes,
      isDetailed: isDetailed ?? this.isDetailed,
    );
  }
}
