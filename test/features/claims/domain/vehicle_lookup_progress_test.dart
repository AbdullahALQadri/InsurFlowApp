import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_progress.dart';

void main() {
  group('VehicleLookupProgress', () {
    test('starts by checking vehicle information', () {
      const progress = VehicleLookupProgress(t: 0);

      expect(
        progress.phaseOf(VehicleLookupItem.vehicle),
        VehicleLookupItemPhase.checking,
      );
      expect(
        progress.phaseOf(VehicleLookupItem.customer),
        VehicleLookupItemPhase.pending,
      );
      expect(
        progress.phaseOf(VehicleLookupItem.policy),
        VehicleLookupItemPhase.pending,
      );
      expect(progress.isComplete, isFalse);
    });

    test('completes checks in vehicle, customer, then policy order', () {
      const mid = VehicleLookupProgress(t: 0.45);
      expect(
        mid.phaseOf(VehicleLookupItem.vehicle),
        VehicleLookupItemPhase.complete,
      );
      expect(
        mid.phaseOf(VehicleLookupItem.customer),
        VehicleLookupItemPhase.checking,
      );
      expect(
        mid.phaseOf(VehicleLookupItem.policy),
        VehicleLookupItemPhase.pending,
      );

      const late = VehicleLookupProgress(t: 0.8);
      expect(
        late.phaseOf(VehicleLookupItem.customer),
        VehicleLookupItemPhase.complete,
      );
      expect(
        late.phaseOf(VehicleLookupItem.policy),
        VehicleLookupItemPhase.checking,
      );
    });

    test('marks every check complete at the end of the lookup', () {
      const done = VehicleLookupProgress(t: 1);
      for (final item in VehicleLookupItem.values) {
        expect(done.phaseOf(item), VehicleLookupItemPhase.complete);
      }
      expect(done.isComplete, isTrue);
    });
  });
}
