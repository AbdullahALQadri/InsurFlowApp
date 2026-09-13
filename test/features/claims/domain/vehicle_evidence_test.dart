import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';

void main() {
  test('starts with every required photo incomplete', () {
    final evidence = VehicleEvidence.checklist(claimId: 'CLM-0001');

    expect(evidence.slots, hasLength(EvidenceCategory.values.length));
    expect(evidence.completedCount, 0);
    expect(evidence.remainingRequiredCount, 7);
    expect(evidence.canContinue, isFalse);
    expect(
      evidence.slots.every((slot) => slot.isRequired && !slot.isComplete),
      isTrue,
    );
  });

  test('enables continue only after all required photos are captured', () {
    var evidence = VehicleEvidence.checklist(claimId: 'CLM-0001');

    for (final category in EvidenceCategory.values) {
      expect(evidence.canContinue, isFalse);
      evidence = evidence.withCaptured(category);
    }

    expect(evidence.completedCount, 7);
    expect(evidence.remainingRequiredCount, 0);
    expect(evidence.canContinue, isTrue);
  });

  test('complete factory marks every required photo captured', () {
    final evidence = VehicleEvidence.complete(claimId: 'CLM-0001');

    expect(evidence.completedCount, 7);
    expect(evidence.remainingRequiredCount, 0);
    expect(evidence.canContinue, isTrue);
    expect(evidence.slots.every((slot) => slot.isComplete), isTrue);
  });
}
