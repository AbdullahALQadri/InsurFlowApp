enum ClaimStatus {
  newClaim,

  /// `PENDING_ACCEPTANCE` returned by `GET /claims`.
  ///
  /// TODO(api): No accept-claim endpoint or acceptance rule is present
  /// in the Flutter project or confirmed in the Postman collection, so
  /// this status is represented faithfully but grants no start/continue
  /// action. Do not treat it as ASSIGNED until the contract confirms it.
  pendingAcceptance,
  assigned,
  inProgress,
  submitted,
  underReview,
  correctionRequired,
  approved,
  rejected,
  closed,
  unknown;

  String get label {
    switch (this) {
      case ClaimStatus.newClaim:
        return 'NEW';
      case ClaimStatus.pendingAcceptance:
        return 'PENDING ACCEPTANCE';
      case ClaimStatus.assigned:
        return 'ASSIGNED';
      case ClaimStatus.inProgress:
        return 'IN PROGRESS';
      case ClaimStatus.submitted:
        return 'SUBMITTED';
      case ClaimStatus.underReview:
        return 'UNDER REVIEW';
      case ClaimStatus.correctionRequired:
        return 'CORRECTION REQUIRED';
      case ClaimStatus.approved:
        return 'APPROVED';
      case ClaimStatus.rejected:
        return 'REJECTED';
      case ClaimStatus.closed:
        return 'CLOSED';
      case ClaimStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String get shortLabel {
    switch (this) {
      case ClaimStatus.newClaim:
        return 'New';
      case ClaimStatus.pendingAcceptance:
        return 'Pending Acceptance';
      case ClaimStatus.assigned:
        return 'Assigned';
      case ClaimStatus.inProgress:
        return 'In Progress';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.correctionRequired:
        return 'Correction';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.closed:
        return 'Closed';
      case ClaimStatus.unknown:
        return 'Unknown';
    }
  }

  int get urgencyRank {
    switch (this) {
      case ClaimStatus.correctionRequired:
        return 0;
      case ClaimStatus.inProgress:
        return 1;
      case ClaimStatus.assigned:
        return 2;
      case ClaimStatus.newClaim:
        // Informational: grouped with un-started claims until the
        // acceptance workflow is confirmed by the backend contract.
        return 3;
      case ClaimStatus.pendingAcceptance:
        return 3;
      case ClaimStatus.submitted:
        return 4;
      case ClaimStatus.underReview:
        return 5;
      case ClaimStatus.rejected:
        return 6;
      case ClaimStatus.approved:
        return 7;
      case ClaimStatus.closed:
        return 8;
      case ClaimStatus.unknown:
        return 9;
    }
  }

  bool get canStart => this == ClaimStatus.assigned;

  /// POST /claims/{id}/inspection/start — ASSIGNED or CORRECTION_REQUIRED.
  bool get canResumeInspection =>
      this == ClaimStatus.assigned || this == ClaimStatus.correctionRequired;

  bool get canContinueInspection =>
      this == ClaimStatus.inProgress || this == ClaimStatus.correctionRequired;

  bool get canEditInspection => canContinueInspection;

  bool get isInspectionLocked =>
      this == ClaimStatus.submitted ||
      this == ClaimStatus.underReview ||
      this == ClaimStatus.approved ||
      this == ClaimStatus.rejected ||
      this == ClaimStatus.closed;

  bool get showsInspectionProgress => canContinueInspection;

  static ClaimStatus parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return ClaimStatus.unknown;
    final normalized = raw
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'NEW':
        return ClaimStatus.newClaim;
      case 'PENDING_ACCEPTANCE':
        return ClaimStatus.pendingAcceptance;
      case 'ASSIGNED':
        return ClaimStatus.assigned;
      case 'IN_PROGRESS':
        return ClaimStatus.inProgress;
      case 'SUBMITTED':
        return ClaimStatus.submitted;
      case 'UNDER_REVIEW':
      case 'UNDERREVIEW':
        return ClaimStatus.underReview;
      case 'CORRECTION_REQUIRED':
      case 'CORRECTION':
        return ClaimStatus.correctionRequired;
      case 'APPROVED':
        return ClaimStatus.approved;
      case 'REJECTED':
        return ClaimStatus.rejected;
      case 'CLOSED':
        return ClaimStatus.closed;
      default:
        return ClaimStatus.unknown;
    }
  }
}
