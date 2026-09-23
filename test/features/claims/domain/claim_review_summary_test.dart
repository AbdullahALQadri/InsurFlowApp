import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

void main() {
  test('pending review reports unknown backend fields honestly', () {
    final summary = ClaimReviewSummary.pending(claimId: 'CLM-0001');

    expect(summary.claimNumber, 'CLM-0001');
    expect(summary.licensePlate, isEmpty);
    expect(summary.makeModel, isEmpty);
    expect(summary.customerName, isEmpty);
    expect(summary.policyNumber, isEmpty);
    expect(summary.policyStatus, PolicyStatus.unknown);
    expect(summary.accidentType, isNull);
    expect(summary.isReady, isFalse);
  });

  test('explicit snapshot is complete for submission', () {
    const summary = ClaimReviewSummary(
      claimId: 'CLM-0001',
      claimNumber: 'CLM-0001',
      licensePlate: 'ABC-1234',
      makeModel: 'Toyota Corolla',
      customerName: 'Ahmed Ali',
      policyNumber: 'POL-102938',
      policyStatus: PolicyStatus.active,
      accidentType: AccidentType.rearEnd,
      locationCaptured: true,
      evidenceCompleted: 7,
      evidenceTotal: 7,
      documentsCompleted: 3,
      documentsTotal: 3,
      signatureCompleted: true,
    );

    expect(summary.evidenceCompleted, 7);
    expect(summary.documentsCompleted, 3);
    expect(summary.isReady, isTrue);
  });
}
