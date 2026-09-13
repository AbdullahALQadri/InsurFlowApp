import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';

void main() {
  test('ready review snapshot is complete for submission', () {
    final summary = ClaimReviewSummary.ready(claimId: 'CLM-0001');

    expect(summary.claimNumber, 'CLM-0001');
    expect(summary.licensePlate, 'ABC-1234');
    expect(summary.makeModel, 'Toyota Corolla');
    expect(summary.customerName, 'Ahmed Ali');
    expect(summary.policyNumber, 'POL-102938');
    expect(summary.evidenceCompleted, 7);
    expect(summary.documentsCompleted, 3);
    expect(summary.isReady, isTrue);
  });
}
