import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';

/// The sections shown on the final review, each backed by a real
/// section of `GET /claims/{id}`.
///
/// There is deliberately no `documents` section: the backend has no
/// document endpoint and stores no document state, so a count here
/// could only come from local app state and would not reflect what the
/// server will validate on submit.
enum ClaimReviewSectionId {
  vehicle,
  customer,
  policy,
  accident,
  location,
  evidence,
  signature,
}

/// Read-only snapshot of the claim as the backend currently holds it.
///
/// Every value is taken from `GET /claims/{id}`. Completeness mirrors
/// what `POST /claims/{id}/inspection/submit` actually checks — it
/// rejects with `Inspection incomplete. Missing: vehicle, accident,
/// location, evidence, signature` — so [isReady] predicts the real
/// outcome instead of tracking local step progress.
class ClaimReviewSummary {
  const ClaimReviewSummary({
    required this.claimId,
    required this.claimNumber,
    this.licensePlate,
    this.makeModel,
    this.vehicleYear,
    this.vehicleColor,
    this.customerName,
    this.customerPhone,
    this.policyNumber,
    this.policyStatus,
    this.accidentType,
    this.accidentDate,
    this.accidentTime,
    this.accidentDescription,
    this.damageDescription,
    this.locationAddress,
    this.locationCoordinates,
    this.evidenceCount = 0,
    this.evidenceThumbnails = const [],
    this.signatureUrl,
    this.signatureCaptured = false,
    this.vehicleLinked = false,
  });

  final String claimId;
  final String claimNumber;

  final String? licensePlate;
  final String? makeModel;
  final int? vehicleYear;
  final String? vehicleColor;

  final String? customerName;
  final String? customerPhone;

  final String? policyNumber;
  final String? policyStatus;

  final String? accidentType;
  final String? accidentDate;
  final String? accidentTime;
  final String? accidentDescription;
  final String? damageDescription;

  final String? locationAddress;
  final String? locationCoordinates;

  final int evidenceCount;

  /// Cloudinary URLs of the uploaded evidence, straight from
  /// `evidence[].url`. Empty when nothing has been uploaded.
  final List<String> evidenceThumbnails;

  /// `signature.url`, or null when no signature is stored.
  final String? signatureUrl;

  final bool signatureCaptured;

  /// True once the vehicle has been resolved against the registry,
  /// which is what `PUT /claims/{id}/vehicle` records.
  final bool vehicleLinked;

  bool get hasAccident => accidentType != null || accidentDescription != null;

  bool get hasLocation =>
      locationCoordinates != null || locationAddress != null;

  bool get hasEvidence => evidenceCount > 0;

  bool get isPolicyActive => policyStatus?.trim().toUpperCase() == 'ACTIVE';

  String? get policyStatusLabel => humanizeEnum(policyStatus);

  String? get accidentTypeLabel => humanizeEnum(accidentType);

  /// The five sections the submit endpoint requires.
  bool get isReady =>
      vehicleLinked &&
      hasAccident &&
      hasLocation &&
      hasEvidence &&
      signatureCaptured;

  /// The sections the backend would still report as missing.
  List<ClaimReviewSectionId> get missingSections => [
    if (!vehicleLinked) ClaimReviewSectionId.vehicle,
    if (!hasAccident) ClaimReviewSectionId.accident,
    if (!hasLocation) ClaimReviewSectionId.location,
    if (!hasEvidence) ClaimReviewSectionId.evidence,
    if (!signatureCaptured) ClaimReviewSectionId.signature,
  ];

  factory ClaimReviewSummary.fromClaim(Claim claim) {
    final accident = claim.accident;
    final location = claim.location;

    return ClaimReviewSummary(
      claimId: claim.id,
      claimNumber: claim.displayNumber,
      licensePlate: claim.plateNumber,
      makeModel: claim.vehicle?.makeModel,
      vehicleYear: claim.vehicle?.year,
      vehicleColor: claim.vehicle?.color,
      customerName: claim.customerName,
      customerPhone: claim.customerPhone,
      policyNumber: claim.policy?.policyNumber,
      policyStatus: claim.policy?.status,
      accidentType: accident?.accidentType,
      accidentDate: accident?.accidentDate,
      accidentTime: accident?.accidentTime,
      accidentDescription: accident?.description,
      damageDescription: accident?.damageDescription,
      locationAddress: location?.address,
      locationCoordinates: location?.coordinatesLabel,
      evidenceCount: claim.evidencePhotos.length,
      evidenceThumbnails: claim.evidencePhotos
          .map((item) => item.url)
          .whereType<String>()
          .toList(),
      signatureUrl: claim.signature?.url,
      signatureCaptured: claim.signature?.hasImage ?? false,
      // The backend treats the vehicle step as done once a policy is
      // linked and the vehicle is resolved, which is exactly what
      // `PUT /claims/{id}/vehicle` writes.
      vehicleLinked: claim.vehicle?.hasSpecification ?? false,
    );
  }
}
