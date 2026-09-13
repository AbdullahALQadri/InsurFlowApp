import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

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
  });

  final String claimId;
  final String backendId;
  final ClaimStatus status;
  final String customerName;
  final String customerPhone;
  final String vehicle;
  final String licensePlate;
  final String street;
  final String city;
  final String assignedBy;
  final DateTime assignedAt;

  factory ClaimAssignment.sample() {
    return ClaimAssignment(
      claimId: 'CLM-0001',
      backendId: 'CLM-0001',
      status: ClaimStatus.assigned,
      customerName: 'Ahmed Ali',
      customerPhone: '059xxxxxxx',
      vehicle: 'Toyota Corolla',
      licensePlate: 'ABC-1234',
      street: 'Al-Quds Street',
      city: 'Tulkarm',
      assignedBy: 'Claims Officer',
      assignedAt: DateTime(2026, 8, 24),
    );
  }

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
      licensePlate: claim.initialPlateNumber ?? '',
      street: parts.isNotEmpty ? parts.first : location,
      city: parts.length > 1 ? parts.sublist(1).join(', ') : '',
      assignedBy: claim.assignedBy ?? '',
      assignedAt: claim.assignedAt ?? claim.createdAt ?? DateTime.now(),
    );
  }

  factory ClaimAssignment.fromPreview(ClaimPreview claim) {
    return ClaimAssignment(
      claimId: claim.displayNumber,
      backendId: claim.id,
      status: claim.status,
      customerName: '',
      customerPhone: '',
      vehicle: claim.vehicle,
      licensePlate: claim.licensePlate,
      street: '',
      city: claim.location,
      assignedBy: '',
      assignedAt: claim.lastUpdated,
    );
  }
}
