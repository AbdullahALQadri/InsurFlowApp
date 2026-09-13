/// Client-side completeness check shown immediately before submit.
enum ClaimValidationItem {
  vehicle,
  policy,
  accident,
  location,
  photos,
  documents,
  signature,
}

/// Staged quality-control timeline. [t] is 0.0–1.0.
class ClaimValidationProgress {
  const ClaimValidationProgress({required this.t});

  final double t;

  static const successAt = 0.90;

  static const completeAt = <ClaimValidationItem, double>{
    ClaimValidationItem.vehicle: 0.10,
    ClaimValidationItem.policy: 0.22,
    ClaimValidationItem.accident: 0.34,
    ClaimValidationItem.location: 0.46,
    ClaimValidationItem.photos: 0.58,
    ClaimValidationItem.documents: 0.70,
    ClaimValidationItem.signature: 0.82,
  };

  bool get isComplete => t >= 1;

  bool get showsSuccess => t >= successAt;

  bool isVisible(ClaimValidationItem item) {
    return t >= (completeAt[item] ?? 1);
  }

  List<ClaimValidationItem> get visibleItems {
    return ClaimValidationItem.values.where(isVisible).toList();
  }
}
