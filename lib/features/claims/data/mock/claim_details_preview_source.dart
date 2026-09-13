import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

/// Product preview values for Claim Details fields the current
/// `GET /claims/{id}` contract does not document.
///
/// TODO(api): Backend GET /claims/{id} does not yet document claimNumber,
/// vehicle make/model, assignedBy, assignedAt, or a structured address.
/// This overlay is applied only to empty fields so the product UI can be
/// reviewed. Remove it once those fields are in the finalized contract.
class ClaimDetailsPreviewSource {
  const ClaimDetailsPreviewSource();

  static const Claim productPreview = Claim(
    id: 'CLM-0001',
    claimNumber: 'CLM-0001',
    status: ClaimStatus.assigned,
    customerName: 'Ahmed Ali',
    customerPhone: '059xxxxxxx',
    vehicleMake: 'Toyota',
    vehicleModel: 'Corolla',
    initialPlateNumber: 'ABC-1234',
    incidentLocation: 'Al-Quds Street, Tulkarm',
    assignedBy: 'Claims Officer',
    assignedAt: null,
  );

  static final DateTime previewAssignedAt = DateTime(2026, 8, 24);

  Claim fillMissing(Claim claim) {
    return claim.copyWith(
      claimNumber: _or(claim.claimNumber, productPreview.claimNumber),
      customerName: _or(claim.customerName, productPreview.customerName),
      customerPhone: _or(claim.customerPhone, productPreview.customerPhone),
      vehicleMake: _or(claim.vehicleMake, productPreview.vehicleMake),
      vehicleModel: _or(claim.vehicleModel, productPreview.vehicleModel),
      initialPlateNumber: _or(
        claim.initialPlateNumber,
        productPreview.initialPlateNumber,
      ),
      incidentLocation: _or(
        claim.incidentLocation,
        productPreview.incidentLocation,
      ),
      assignedBy: _or(claim.assignedBy, productPreview.assignedBy),
      assignedAt: claim.assignedAt ?? claim.createdAt ?? previewAssignedAt,
    );
  }

  static String? _or(String? value, String? fallback) {
    if (value != null && value.trim().isNotEmpty) return value;
    return fallback;
  }
}
