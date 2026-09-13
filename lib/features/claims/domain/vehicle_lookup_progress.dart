enum VehicleLookupItem { vehicle, customer, policy }

enum VehicleLookupItemPhase { pending, checking, complete }

/// Staged secure-lookup timeline. [t] is 0.0–1.0.
class VehicleLookupProgress {
  const VehicleLookupProgress({required this.t});

  final double t;

  static const vehicleCompleteAt = 0.30;
  static const customerStartAt = 0.26;
  static const customerCompleteAt = 0.64;
  static const policyStartAt = 0.60;
  static const policyCompleteAt = 0.94;

  bool get isComplete => t >= 1;

  VehicleLookupItemPhase phaseOf(VehicleLookupItem item) {
    switch (item) {
      case VehicleLookupItem.vehicle:
        if (t >= vehicleCompleteAt) return VehicleLookupItemPhase.complete;
        return VehicleLookupItemPhase.checking;
      case VehicleLookupItem.customer:
        if (t >= customerCompleteAt) return VehicleLookupItemPhase.complete;
        if (t >= customerStartAt) return VehicleLookupItemPhase.checking;
        return VehicleLookupItemPhase.pending;
      case VehicleLookupItem.policy:
        if (t >= policyCompleteAt) return VehicleLookupItemPhase.complete;
        if (t >= policyStartAt) return VehicleLookupItemPhase.checking;
        return VehicleLookupItemPhase.pending;
    }
  }
}
