import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/incident_coordinates.dart';

/// Lightweight presentation mapping for assignment screens.
///
/// TODO(api): `assignedBy` / `assignedAt` are NOT part of the confirmed
/// `GET /claims` response — they stay null/empty until a confirmed
/// contract provides them. `assignedTo` comes from `assignedTo`/`fieldAdjuster`
/// and must never be shown as `assignedBy`.
class ClaimAssignment {
  const ClaimAssignment({
    required this.claimId,
    required this.backendId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.vehicle,
    required this.licensePlate,
    required this.street,
    required this.city,
    required this.assignedBy,
    required this.assignedAt,
    this.assignedToName = '',
    this.coordinates,
    this.attentionNote,
    this.priority,
    this.completedSteps = 0,
    this.totalSteps = 8,
    this.lastUpdated,
  });

  factory ClaimAssignment.fromClaim(Claim claim) {
    final location = claim.incidentLocation ?? '';
    final parts = location
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return ClaimAssignment(
      claimId: claim.displayNumber,
      backendId: claim.id,
      status: claim.status,
      customerName: claim.customerName ?? '',
      customerPhone: claim.customerPhone ?? '',
      vehicle: claim.vehicleDisplay,
      // GET /claims returns `initialPlateNumber` (e.g. "ABC-51").
      licensePlate: claim.initialPlateNumber ?? '',
      street: parts.isNotEmpty ? parts.first : '',
      city: parts.length > 1 ? parts.sublist(1).join(', ') : '',
      // Not present in the current contract — stays empty so the UI
      // shows its "not available" state instead of a fabricated value.
      assignedBy: claim.assignedBy ?? '',
      assignedAt: claim.assignedAt,
      assignedToName:
          (claim.assignedTo?.name ?? claim.fieldAdjuster?.name ?? '').trim(),
      coordinates: claim.incidentCoordinates,
      attentionNote: claim.notes,
      priority: claim.priority,
      lastUpdated: claim.updatedAt ?? claim.assignedAt ?? claim.createdAt,
    );
  }

  factory ClaimAssignment.fromPreview(ClaimPreview claim) {
    final location = claim.location;
    final parts = location
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return ClaimAssignment(
      claimId: claim.displayNumber,
      backendId: claim.id,
      status: claim.status,
      customerName: '',
      customerPhone: '',
      vehicle: claim.vehicle,
      licensePlate: claim.licensePlate,
      street: parts.isNotEmpty ? parts.first : '',
      city: parts.length > 1 ? parts.sublist(1).join(', ') : '',
      assignedBy: '',
      assignedAt: null,
      attentionNote: claim.attentionNote,
      lastUpdated: claim.lastUpdated,
    );
  }

  final String claimId;
  final String backendId;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final String licensePlate;
  final String street;
  final String city;
  final String? attentionNote;
  final ClaimStatus status;
  final String? priority;

  /// Person who assigned the claim. Empty when the backend has not
  /// confirmed this field — never populated from `assignedTo`.
  final String assignedBy;

  /// Person the claim is assigned to (`assignedTo` / `fieldAdjuster`).
  final String assignedToName;

  /// Assignment timestamp. Null when the backend has not confirmed it —
  /// never derived from unrelated timestamps.
  final DateTime? assignedAt;

  /// GPS fix from `incidentCoordinates`; null when unavailable.
  final IncidentCoordinates? coordinates;

  final int completedSteps;
  final int totalSteps;
  final DateTime? lastUpdated;
}
