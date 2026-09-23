import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';
import 'package:insurflow/features/claims/domain/entities/incident_coordinates.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';

class Claim {
  const Claim({
    required this.id,
    required this.status,
    this.claimNumber,
    this.statusRaw,
    this.customerName,
    this.customerPhone,
    this.vehicleMake,
    this.vehicleModel,
    this.initialPlateNumber,
    this.incidentType,
    this.incidentLocation,
    this.adjusterId,
    this.priority,
    this.notes,
    this.assignedBy,
    this.assignedAt,
    this.assignedTo,
    this.fieldAdjuster,
    this.incidentCoordinates,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final ClaimStatus status;
  final String? claimNumber;
  final String? statusRaw;
  final String? customerName;
  final String? customerPhone;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? initialPlateNumber;
  final String? incidentType;
  final String? incidentLocation;
  final String? adjusterId;
  final String? priority;
  final String? notes;

  /// Person who assigned the claim. Not present in the current
  /// `GET /claims` response — never populate this from `assignedTo`.
  final String? assignedBy;
  final DateTime? assignedAt;

  /// Person the claim is assigned to (`assignedTo` in the API).
  final ClaimAssignee? assignedTo;

  /// Field adjuster on the claim (`fieldAdjuster` in the API).
  final ClaimAssignee? fieldAdjuster;

  /// GPS fix (`incidentCoordinates` in the API); null when absent.
  final IncidentCoordinates? incidentCoordinates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayNumber =>
      claimNumber?.trim().isNotEmpty == true ? claimNumber!.trim() : id;

  String get vehicleDisplay {
    final make = vehicleMake?.trim() ?? '';
    final model = vehicleModel?.trim() ?? '';
    if (make.isNotEmpty && model.isNotEmpty) return '$make $model';
    if (make.isNotEmpty) return make;
    if (model.isNotEmpty) return model;
    return '';
  }

  DateTime get lastUpdated =>
      updatedAt ?? assignedAt ?? createdAt ?? DateTime.now();

  ClaimPreview toPreview() {
    return ClaimPreview(
      id: id,
      claimNumber: claimNumber,
      vehicle: vehicleDisplay.isNotEmpty
          ? vehicleDisplay
          : (initialPlateNumber ?? ''),
      vehicleYear: 0,
      licensePlate: initialPlateNumber ?? '',
      location: incidentLocation ?? '',
      status: status,
      lastUpdated: lastUpdated,
      completedSteps: InspectionProgress.forClaim(this).completedCount,
      totalSteps: InspectionProgress.totalCount,
    );
  }

  Claim copyWith({
    String? id,
    ClaimStatus? status,
    String? claimNumber,
    String? statusRaw,
    String? customerName,
    String? customerPhone,
    String? vehicleMake,
    String? vehicleModel,
    String? initialPlateNumber,
    String? incidentType,
    String? incidentLocation,
    String? adjusterId,
    String? priority,
    String? notes,
    String? assignedBy,
    DateTime? assignedAt,
    ClaimAssignee? assignedTo,
    ClaimAssignee? fieldAdjuster,
    IncidentCoordinates? incidentCoordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Claim(
      id: id ?? this.id,
      status: status ?? this.status,
      claimNumber: claimNumber ?? this.claimNumber,
      statusRaw: statusRaw ?? this.statusRaw,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      initialPlateNumber: initialPlateNumber ?? this.initialPlateNumber,
      incidentType: incidentType ?? this.incidentType,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      adjusterId: adjusterId ?? this.adjusterId,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      fieldAdjuster: fieldAdjuster ?? this.fieldAdjuster,
      incidentCoordinates: incidentCoordinates ?? this.incidentCoordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
