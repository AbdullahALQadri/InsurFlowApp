import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/inspection_progress_store.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

/// Snapshot of inspection fields shown on the final claim review.
///
/// TODO(api):
/// Vehicle, customer, and policy values must come from
/// `GET /claims/{id}` (or a persisted local lookup result). Until that
/// contract is wired, [ClaimReviewSummary.pending] reports those fields
/// as empty instead of fabricating them. Do not invent response fields.
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

  /// Null until the accident details step has actually been completed.
  final AccidentType? accidentType;
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

  /// Review state assembled only from facts the app actually knows:
  /// the local inspection-step progress. Nothing here is invented —
  /// vehicle/customer/policy stay empty until the backend contract
  /// provides them, so `isReady` honestly reports "not ready".
  factory ClaimReviewSummary.pending({required String claimId}) {
    final reached = InspectionProgressStore.instance.indexFor(claimId) ?? 0;
    bool done(InspectionStepId step) => reached > step.index;

    return ClaimReviewSummary(
      claimId: claimId,
      claimNumber: claimId,
      licensePlate: '',
      makeModel: '',
      customerName: '',
      policyNumber: '',
      policyStatus: PolicyStatus.unknown,
      accidentType: null,
      accidentDateComplete: done(InspectionStepId.accident),
      accidentTimeComplete: done(InspectionStepId.accident),
      accidentDescriptionComplete: done(InspectionStepId.accident),
      locationCaptured: done(InspectionStepId.location),
      evidenceCompleted: done(InspectionStepId.evidence)
          ? VehicleEvidence.requiredCount
          : 0,
      evidenceTotal: VehicleEvidence.requiredCount,
      documentsCompleted: done(InspectionStepId.documents)
          ? ClaimDocuments.requiredCount
          : 0,
      documentsTotal: ClaimDocuments.requiredCount,
      signatureCompleted: done(InspectionStepId.signature),
    );
  }
}
