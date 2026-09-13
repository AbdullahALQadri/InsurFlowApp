import 'package:insurflow/features/claims/domain/claim_status.dart';

class ClaimPreview {
  const ClaimPreview({
    required this.id,
    required this.vehicle,
    required this.vehicleYear,
    required this.licensePlate,
    required this.location,
    required this.status,
    required this.lastUpdated,
    this.claimNumber,
    this.attentionNote,
    this.completedSteps = 0,
    this.totalSteps = 8,
  });

  /// Backend claim id used for API calls.
  final String id;
  final String? claimNumber;
  final String vehicle;
  final int vehicleYear;
  final String licensePlate;
  final String location;
  final ClaimStatus status;
  final DateTime lastUpdated;
  final String? attentionNote;
  final int completedSteps;
  final int totalSteps;

  String get displayNumber =>
      (claimNumber != null && claimNumber!.trim().isNotEmpty)
      ? claimNumber!.trim()
      : id;
}
