import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';

void main() {
  test('a snapshot with every backend section is ready to submit', () {
    const summary = ClaimReviewSummary(
      claimId: '6a91ab09c9ff1dc54fabf15b',
      claimNumber: 'CLM-0001',
      licensePlate: 'ABC-1234',
      makeModel: 'Toyota Corolla',
      vehicleYear: 2022,
      customerName: 'Ahmed Ali',
      policyNumber: 'POL-102938',
      policyStatus: 'ACTIVE',
      accidentType: 'REAR_END_COLLISION',
      accidentDate: '2026-08-28',
      accidentTime: '14:30',
      accidentDescription: 'Hit from behind at a red light.',
      locationAddress: 'King Fahd Road, Riyadh',
      locationCoordinates: '24.7136, 46.6753',
      evidenceCount: 1,
      signatureCaptured: true,
      vehicleLinked: true,
    );

    expect(summary.isReady, isTrue);
    expect(summary.missingSections, isEmpty);
    expect(summary.isPolicyActive, isTrue);
    expect(summary.accidentTypeLabel, 'Rear End Collision');
  });

  test('missing sections match what the submit endpoint rejects on', () {
    const summary = ClaimReviewSummary(
      claimId: '6a91ab09c9ff1dc54fabf15b',
      claimNumber: 'CLM-0001',
      licensePlate: 'ABC-1234',
      customerName: 'Ahmed Ali',
    );

    expect(summary.isReady, isFalse);
    expect(summary.missingSections, [
      ClaimReviewSectionId.vehicle,
      ClaimReviewSectionId.accident,
      ClaimReviewSectionId.location,
      ClaimReviewSectionId.evidence,
      ClaimReviewSectionId.signature,
    ]);
  });

  test('an unknown policy status is reported, not guessed', () {
    const summary = ClaimReviewSummary(
      claimId: 'c1',
      claimNumber: 'CLM-0001',
      policyStatus: 'LAPSED',
    );

    expect(summary.isPolicyActive, isFalse);
    expect(summary.policyStatusLabel, 'Lapsed');
  });
}
