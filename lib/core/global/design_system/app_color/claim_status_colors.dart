import 'package:flutter/material.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

class ClaimStatusColors {
  ClaimStatusColors._();

  static const Color assigned = Color(0xFF00A3C4);
  static const Color inProgress = Color(0xFF1D4ED8);
  static const Color correctionRequired = Color(0xFFD97706);
  static const Color submitted = Color(0xFF0F9D8A);
  static const Color underReview = Color(0xFF6366F1);
  static const Color approved = Color(0xFF047857);
  static const Color rejected = Color(0xFFB91C1C);
  static const Color newClaim = Color(0xFF64748B);

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
