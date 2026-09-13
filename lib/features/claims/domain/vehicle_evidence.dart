/// Required vehicle photo checklist for a field inspection.
///
/// TODO(api):
/// Waiting for the Backend evidence upload endpoint.
/// Replace local capture state once the API is available in the
/// Postman collection. Do not invent upload routes or response fields.
enum EvidenceCategory {
  licensePlate,
  front,
  rear,
  leftSide,
  rightSide,
  damageCloseUp,
  accidentScene,
}

enum EvidenceCaptureStatus { incomplete, completed }

class EvidenceSlot {
  const EvidenceSlot({
    required this.category,
    this.status = EvidenceCaptureStatus.incomplete,
  });

  final EvidenceCategory category;
  final EvidenceCaptureStatus status;

  bool get isRequired => true;

  bool get isComplete => status == EvidenceCaptureStatus.completed;

  EvidenceSlot captured() {
    return EvidenceSlot(
      category: category,
      status: EvidenceCaptureStatus.completed,
    );
  }
}

class VehicleEvidence {
  const VehicleEvidence({required this.claimId, required this.slots});

  final String claimId;
  final List<EvidenceSlot> slots;

  static const requiredCount = 7;

  factory VehicleEvidence.checklist({required String claimId}) {
    return VehicleEvidence(
      claimId: claimId,
      slots: [
        for (final category in EvidenceCategory.values)
          EvidenceSlot(category: category),
      ],
    );
  }

  factory VehicleEvidence.complete({required String claimId}) {
    var evidence = VehicleEvidence.checklist(claimId: claimId);
    for (final category in EvidenceCategory.values) {
      evidence = evidence.withCaptured(category);
    }
    return evidence;
  }

  int get completedCount => slots.where((slot) => slot.isComplete).length;

  int get totalCount => slots.length;

  int get remainingRequiredCount =>
      slots.where((slot) => slot.isRequired && !slot.isComplete).length;

  bool get canContinue =>
      slots.every((slot) => !slot.isRequired || slot.isComplete);

  VehicleEvidence withCaptured(EvidenceCategory category) {
    return VehicleEvidence(
      claimId: claimId,
      slots: [
        for (final slot in slots)
          if (slot.category == category) slot.captured() else slot,
      ],
    );
  }
}
