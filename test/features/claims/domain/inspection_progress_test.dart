import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/inspection_progress_store.dart';

import '../../../helpers/fixtures.dart';

void main() {
  setUp(() => InspectionProgressStore.instance.reset());

  test('field inspection starts at Vehicle with 0 of 8 complete', () {
    const progress = InspectionProgress.fieldInspectionStarted;

    expect(progress.completedCount, 0);
    expect(InspectionProgress.totalCount, 8);
    expect(progress.currentStep, InspectionStepId.vehicle);
    expect(progress.lastCompletedStep, isNull);
    expect(
      progress.phaseOf(InspectionStepId.vehicle),
      InspectionStepPhase.current,
    );
    expect(
      progress.phaseOf(InspectionStepId.accident),
      InspectionStepPhase.upcoming,
    );
    expect(
      progress.phaseOf(InspectionStepId.submission),
      InspectionStepPhase.upcoming,
    );
  });

  test('IN_PROGRESS claims start at the vehicle inspection step', () {
    final progress = InspectionProgress.forClaim(
      testClaim(status: ClaimStatus.inProgress),
    );

    expect(progress.currentIndex, 0);
    expect(progress.currentStep, InspectionStepId.vehicle);
    expect(progress.completedCount, 0);
  });

  test('ASSIGNED claims do not skip ahead in the stepper', () {
    final progress = InspectionProgress.forClaim(testClaim());
    expect(progress.currentIndex, 0);
    expect(progress.currentStep, InspectionStepId.vehicle);
  });

  test('completing steps advances local progress for a claim', () {
    final claim = testClaim(status: ClaimStatus.inProgress);
    InspectionProgress.start(claim.id);
    InspectionProgress.complete(claim.id, InspectionStepId.vehicle);
    InspectionProgress.complete(claim.id, InspectionStepId.accident);

    final progress = InspectionProgress.forClaim(claim);
    expect(progress.completedCount, 2);
    expect(progress.currentStep, InspectionStepId.location);
    expect(progress.lastCompletedStep, InspectionStepId.accident);
  });

  test('submitted claims show all 8 inspection steps complete', () {
    final progress = InspectionProgress.forClaim(
      testClaim(status: ClaimStatus.submitted),
    );
    expect(progress.completedCount, 8);
    expect(progress.hasCurrent, isFalse);
  });

  test('ClaimStatus.showsInspectionProgress is true for in-progress work', () {
    expect(ClaimStatus.inProgress.showsInspectionProgress, isTrue);
    expect(ClaimStatus.correctionRequired.showsInspectionProgress, isTrue);
    expect(ClaimStatus.assigned.showsInspectionProgress, isFalse);
    expect(ClaimStatus.submitted.showsInspectionProgress, isFalse);
    expect(ClaimStatus.underReview.isInspectionLocked, isTrue);
  });
}
