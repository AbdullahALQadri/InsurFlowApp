import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/claim_validation_progress.dart';

void main() {
  group('ClaimValidationProgress', () {
    test('hides every check at the start', () {
      const progress = ClaimValidationProgress(t: 0);

      expect(progress.visibleItems, isEmpty);
      expect(progress.showsSuccess, isFalse);
      expect(progress.isComplete, isFalse);
    });

    test('reveals checks in quality-control order', () {
      const early = ClaimValidationProgress(t: 0.15);
      expect(early.isVisible(ClaimValidationItem.vehicle), isTrue);
      expect(early.isVisible(ClaimValidationItem.policy), isFalse);

      const mid = ClaimValidationProgress(t: 0.5);
      expect(mid.isVisible(ClaimValidationItem.location), isTrue);
      expect(mid.isVisible(ClaimValidationItem.photos), isFalse);
      expect(mid.showsSuccess, isFalse);

      const late = ClaimValidationProgress(t: 0.75);
      expect(late.isVisible(ClaimValidationItem.documents), isTrue);
      expect(late.isVisible(ClaimValidationItem.signature), isFalse);
    });

    test('shows success then marks the checkpoint complete', () {
      const success = ClaimValidationProgress(t: 0.92);
      expect(success.showsSuccess, isTrue);
      expect(success.isComplete, isFalse);
      expect(
        success.visibleItems,
        hasLength(ClaimValidationItem.values.length),
      );

      const done = ClaimValidationProgress(t: 1);
      expect(done.showsSuccess, isTrue);
      expect(done.isComplete, isTrue);
    });
  });
}
