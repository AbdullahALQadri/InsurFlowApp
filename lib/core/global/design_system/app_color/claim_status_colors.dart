import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

/// Status colours for claims.
///
/// Deliberately constant across themes: a status colour is data, and it
/// must mean the same thing in light and dark. Values come from
/// [AppPalette] so they live with the rest of the palette.
class ClaimStatusColors {
  ClaimStatusColors._();

  static const Color assigned = AppPalette.cyan;
  static const Color inProgress = Color(0xFF1D4ED8);
  static const Color correctionRequired = AppPalette.warning;
  static const Color submitted = AppPalette.success;
  static const Color underReview = AppPalette.info;
  static const Color approved = AppPalette.successStrong;
  static const Color rejected = AppPalette.dangerStrong;
  static const Color newClaim = AppPalette.neutral;

  static Color of(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.newClaim:
        return newClaim;
      case ClaimStatus.pendingAcceptance:
        // Neutral pending tone until the acceptance workflow is
        // confirmed by the backend contract.
        return newClaim;
      case ClaimStatus.assigned:
        return assigned;
      case ClaimStatus.inProgress:
        return inProgress;
      case ClaimStatus.correctionRequired:
        return correctionRequired;
      case ClaimStatus.submitted:
        return submitted;
      case ClaimStatus.underReview:
        return underReview;
      case ClaimStatus.approved:
        return approved;
      case ClaimStatus.rejected:
        return rejected;
      case ClaimStatus.closed:
        return const Color(0xFF475569);
      case ClaimStatus.unknown:
        return const Color(0xFF64748B);
    }
  }
}
