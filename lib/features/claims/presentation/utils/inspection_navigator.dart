import 'package:flutter/widgets.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/inspection_progress_store.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_review_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/location_permission_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';

class InspectionNavigator {
  const InspectionNavigator._();

  static InspectionStepId currentStep(String claimId) {
    final stored = InspectionProgressStore.instance.indexFor(claimId) ?? 0;
    if (stored >= InspectionStepId.values.length) {
      return InspectionStepId.submission;
    }
    return InspectionStepId.values[stored.clamp(
      0,
      InspectionStepId.values.length - 1,
    )];
  }

  static Future<dynamic> openCurrent(
    BuildContext context, {
    required String claimId,
  }) {
    return openStep(context, claimId: claimId, step: currentStep(claimId));
  }

  static Future<dynamic> openStep(
    BuildContext context, {
    required String claimId,
    required InspectionStepId step,
  }) {
    switch (step) {
      case InspectionStepId.vehicle:
        return VehicleIdentificationScreen.open(context, claimId: claimId);
      case InspectionStepId.accident:
        return AccidentDetailsScreen.open(context, claimId: claimId);
      case InspectionStepId.location:
        return LocationPermissionScreen.open(context, claimId: claimId);
      case InspectionStepId.evidence:
        return VehicleEvidenceScreen.open(context, claimId: claimId);
      case InspectionStepId.signature:
        return CustomerSignatureScreen.open(context, claimId: claimId);
      case InspectionStepId.review:
        return ClaimReviewScreen.open(context, claimId: claimId);
      case InspectionStepId.submission:
        return ClaimValidationScreen.open(context, claimId: claimId);
    }
  }

  static Future<dynamic> completeAndContinue(
    BuildContext context, {
    required String claimId,
    required InspectionStepId completed,
  }) {
    InspectionProgress.complete(claimId, completed);
    final nextIndex = completed.index + 1;
    if (nextIndex >= InspectionStepId.values.length) {
      return ClaimValidationScreen.open(context, claimId: claimId);
    }
    return openStep(
      context,
      claimId: claimId,
      step: InspectionStepId.values[nextIndex],
    );
  }
}
