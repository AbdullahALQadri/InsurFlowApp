import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';

/// Row-level view of a claim for the list screens.
///
/// Built from `GET /claims`, which returns `claimNumber`, `status`,
/// `customerName`, `initialPlateNumber`, `createdAt` and the assignee
/// objects. `make`/`model`/`year` are NOT part of that response — they
/// only arrive with `GET /claims/{id}` — so [vehicle] is empty for a
/// list-loaded claim and the card renders the plate instead.
class ClaimPreview {
  const ClaimPreview({
    required this.id,
    required this.vehicle,
    required this.licensePlate,
    required this.location,
    required this.status,
    required this.lastUpdated,
    this.claimNumber,
    this.customerName,
    this.priority,
    this.attentionNote,
    this.completedSteps = 0,
    this.totalSteps = 8,
  });

  /// Backend claim id used for API calls.
  final String id;
  final String? claimNumber;

  /// `make model`. Empty on a list-loaded claim — see the class doc.
  final String vehicle;
  final String licensePlate;
  final String location;
  final ClaimStatus status;
  final DateTime lastUpdated;

  /// `customerName` from the list response.
  final String? customerName;

  /// `assignment.priority`, detail response only.
  final String? priority;

  final String? attentionNote;
  final int completedSteps;
  final int totalSteps;

  String get displayNumber =>
      (claimNumber != null && claimNumber!.trim().isNotEmpty)
      ? claimNumber!.trim()
      : id;

  bool get hasVehicleSpecification => vehicle.trim().isNotEmpty;

  String? get priorityLabel => humanizeEnum(priority);
}
