/// Required vehicle photo checklist for a field inspection.
///
/// Each slot is uploaded individually through
/// `POST /claims/{id}/evidence` as multipart `file` + `imageType`.
enum EvidenceCategory {
  licensePlate,
  front,
  rear,
  leftSide,
  rightSide,
  damageCloseUp,
  accidentScene,
}

extension EvidenceCategoryApi on EvidenceCategory {
  /// The `imageType` this slot is uploaded as.
  ///
  /// The backend accepts exactly six values — VEHICLE_FRONT,
  /// VEHICLE_REAR, VEHICLE_SIDE, DAMAGE_CLOSEUP, DRIVER_LICENSE and
  /// OTHER — and the app's checklist is finer grained than that, so two
  /// mappings are deliberately lossy:
  ///
  /// * left and right side both upload as VEHICLE_SIDE, because the
  ///   backend draws no left/right distinction;
  /// * the plate shot and the wide scene shot both upload as OTHER,
  ///   since neither is a driver licence and no closer value exists.
  ///
  /// The checklist still tracks them separately on the device, so the
  /// adjuster is still prompted for each one.
  String get apiValue {
    switch (this) {
      case EvidenceCategory.front:
        return 'VEHICLE_FRONT';
      case EvidenceCategory.rear:
        return 'VEHICLE_REAR';
      case EvidenceCategory.leftSide:
      case EvidenceCategory.rightSide:
        return 'VEHICLE_SIDE';
      case EvidenceCategory.damageCloseUp:
        return 'DAMAGE_CLOSEUP';
      case EvidenceCategory.licensePlate:
      case EvidenceCategory.accidentScene:
        return 'OTHER';
    }
  }
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
