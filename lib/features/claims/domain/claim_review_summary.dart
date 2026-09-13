import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

/// Snapshot of inspection fields shown on the final claim review.
///
/// TODO(api):
/// Waiting for a Backend submit-claim endpoint in the Postman collection.
/// This review is assembled from local inspection data until a reliable
/// submit contract exists. Do not invent POST routes or response fields.
enum ClaimReviewSectionId {
  vehicle,
  customer,
  policy,
  accident,
  location,
  evidence,
  documents,
  signature,
}

class ClaimReviewSummary {
  const ClaimReviewSummary({
    required this.claimId,
    required this.claimNumber,
    required this.licensePlate,
    required this.makeModel,
    required this.customerName,
    required this.policyNumber,
    required this.policyStatus,
    required this.accidentType,
    required this.locationCaptured,
    required this.evidenceCompleted,
    required this.evidenceTotal,
    required this.documentsCompleted,
    required this.documentsTotal,
    required this.signatureCompleted,
    this.accidentDateComplete = true,
    this.accidentTimeComplete = true,
    this.accidentDescriptionComplete = true,
  });

  final String claimId;
  final String claimNumber;
  final String licensePlate;
  final String makeModel;
  final String customerName;
  final String policyNumber;
  final PolicyStatus policyStatus;
  final AccidentType accidentType;
  final bool accidentDateComplete;
  final bool accidentTimeComplete;
  final bool accidentDescriptionComplete;
  final bool locationCaptured;
  final int evidenceCompleted;
  final int evidenceTotal;
  final int documentsCompleted;
  final int documentsTotal;
  final bool signatureCompleted;

  bool get isReady =>
      licensePlate.isNotEmpty &&
      makeModel.isNotEmpty &&
      customerName.isNotEmpty &&
      policyNumber.isNotEmpty &&
      accidentDateComplete &&
      accidentTimeComplete &&
      accidentDescriptionComplete &&
      locationCaptured &&
      evidenceCompleted >= evidenceTotal &&
      documentsCompleted >= documentsTotal &&
      signatureCompleted;

  factory ClaimReviewSummary.ready({required String claimId}) {
    final vehicle = VehicleLookupResult.demo(claimId: claimId);
    return ClaimReviewSummary(
      claimId: claimId,
      claimNumber: claimId,
      licensePlate: vehicle.licensePlate,
      makeModel: vehicle.makeModel,
      customerName: vehicle.customerName,
      policyNumber: vehicle.policyNumber,
      policyStatus: vehicle.policyStatus,
      accidentType: AccidentType.rearEnd,
      locationCaptured: true,
      evidenceCompleted: VehicleEvidence.requiredCount,
      evidenceTotal: VehicleEvidence.requiredCount,
      documentsCompleted: ClaimDocuments.requiredCount,
      documentsTotal: ClaimDocuments.requiredCount,
      signatureCompleted: true,
    );
  }
}
