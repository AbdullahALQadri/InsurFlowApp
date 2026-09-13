import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/inspection_progress_store.dart';

enum InspectionStepId {
  vehicle,
  accident,
  location,
  evidence,
  documents,
  signature,
  review,
  submission,
}

enum InspectionStepPhase { completed, current, upcoming }

/// Field-inspection workflow. [currentIndex] is the active step;
/// every step before it is complete.
class InspectionProgress {
  const InspectionProgress({required this.currentIndex});

  /// Product snapshot after Start Claim: Vehicle is the current step.
  static const fieldInspectionStarted = InspectionProgress(currentIndex: 0);

  final int currentIndex;

  static int get totalCount => InspectionStepId.values.length;

  int get workStep {
    if (currentIndex >= totalCount) return totalCount;
    return currentIndex + 1;
  }

  int get completedCount => currentIndex.clamp(0, totalCount);

  bool get hasCurrent => currentIndex >= 0 && currentIndex < totalCount;

  InspectionStepId? get currentStep =>
      hasCurrent ? InspectionStepId.values[currentIndex] : null;

  InspectionStepId? get lastCompletedStep {
    if (completedCount <= 0) return null;
    return InspectionStepId.values[completedCount - 1];
  }

  InspectionStepPhase phaseOf(InspectionStepId id) {
    final index = id.index;
    if (index < currentIndex) return InspectionStepPhase.completed;
    if (index == currentIndex && hasCurrent) {
      return InspectionStepPhase.current;
    }
    return InspectionStepPhase.upcoming;
  }

  factory InspectionProgress.forClaim(Claim claim) {
    if (claim.status.isInspectionLocked) {
      return InspectionProgress(currentIndex: totalCount);
    }
    final stored = InspectionProgressStore.instance.indexFor(claim.id);
    if (stored != null) {
      return InspectionProgress(currentIndex: stored);
    }
    if (claim.status.canContinueInspection) {
      return fieldInspectionStarted;
    }
    return const InspectionProgress(currentIndex: 0);
  }

  static void start(String claimId) {
    InspectionProgressStore.instance.start(claimId);
  }

  static void complete(String claimId, InspectionStepId step) {
    InspectionProgressStore.instance.completeThrough(claimId, step.index + 1);
  }

  static void completeAll(String claimId) {
    InspectionProgressStore.instance.completeAll(claimId);
  }
}
