import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_location_map.dart';
import 'package:insurflow/features/claims/presentation/widgets/assignment_info_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_evidence_gallery.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_timeline_view.dart';
import 'package:insurflow/features/claims/presentation/widgets/policy_active_badge.dart';

/// The read-only sections of a claim, built strictly from what
/// `GET /claims/{id}` returned.
///
/// Rules applied throughout:
/// * A section renders only when the backend sent data for it.
/// * A section that is genuinely empty on the server (a fresh claim has
///   `accident`, `location`, `policy` and `signature` all null) states
///   that in words rather than showing a substitute value.
/// * A row renders only when its own field is non-null.
///
/// Only [Claim.isDetailed] claims carry these sections; a list-loaded
/// claim has none of them and the sections are skipped rather than
/// shown as empty.
class ClaimDetailSections extends StatelessWidget {
  const ClaimDetailSections({super.key, required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final sections = <Widget?>[
      _customer(context, strings),
      _vehicle(context, strings),
      _policy(context, strings),
      _accident(context, strings),
      _reportedIncident(context, strings),
      _capturedLocation(context, strings),
      _evidence(context, strings),
      _signature(context, strings),
      _assignment(context, strings),
      _correction(context, strings),
      _closure(context, strings),
      _activity(context, strings),
    ].whereType<Widget>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) context.addVerticalSpace(12),
          sections[i],
        ],
      ],
    );
  }

  // --- `customer` ---------------------------------------------------------

  Widget? _customer(BuildContext context, AppStrings strings) {
    final name = claim.customerName;
    final phone = claim.customerPhone;
    if (name == null && phone == null) return null;

    return AssignmentInfoCard(
      label: strings.customer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentInfoRow(label: strings.customerNameLabel, value: name),
          AssignmentInfoRow(label: strings.customerPhoneLabel, value: phone),
        ],
      ),
    );
  }

  // --- `vehicle` ----------------------------------------------------------

  Widget? _vehicle(BuildContext context, AppStrings strings) {
    final vehicle = claim.vehicle;
    final plate = claim.plateNumber;
    if (vehicle == null && plate == null) return null;

    return AssignmentInfoCard(
      label: strings.vehicle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentInfoRow(label: strings.plateNumberLabel, value: plate),
          AssignmentInfoRow(
            label: strings.makeModelLabel,
            value: vehicle?.makeModel,
          ),
          AssignmentInfoRow(
            label: strings.yearLabel,
            value: vehicle?.year?.toString(),
          ),
          AssignmentInfoRow(
            label: strings.colorLabel,
            value: vehicle?.color == null
                ? null
                : strings.vehicleColorLabel(vehicle!.color!),
          ),
          // The claim keeps the plate from the original report until the
          // adjuster resolves the vehicle against the registry.
          if (!(vehicle?.hasSpecification ?? false))
            AssignmentEmptyNote(message: strings.noVehicleDetailsYet),
        ],
      ),
    );
  }

  // --- `policy` -----------------------------------------------------------

  Widget? _policy(BuildContext context, AppStrings strings) {
    if (!claim.isDetailed) return null;
    final policy = claim.policy;

    return AssignmentInfoCard(
      label: strings.claimPolicy,
      child: policy == null
          ? AssignmentEmptyNote(message: strings.noPolicyLinkedYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssignmentInfoRow(
                  label: strings.policyNumberLabel,
                  value: policy.policyNumber,
                ),
                if (policy.status != null)
                  AssignmentInfoRow(
                    label: strings.policyStatusFieldLabel,
                    value: null,
                    valueWidget: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: policy.isActive
                          ? PolicyActiveBadge(
                              label: strings.policyStatusLabel(policy.status)!,
                            )
                          : Text(
                              strings.policyStatusLabel(policy.status)!,
                              style: context.font16Bold?.copyWith(
                                color: context.colors.textPrimaryColor,
                                fontWeight: FontWeightHelper.semiBold,
                              ),
                            ),
                    ),
                  ),
                if (policy.startDate != null && policy.expiryDate != null)
                  AssignmentInfoRow(
                    label: strings.policyPeriodLabel,
                    value: ClaimDateFormatter.dateRange(
                      strings,
                      policy.startDate!,
                      policy.expiryDate!,
                    ),
                  ),
              ],
            ),
    );
  }

  // --- `accident` ---------------------------------------------------------

  Widget? _accident(BuildContext context, AppStrings strings) {
    if (!claim.isDetailed) return null;
    final accident = claim.accident;

    return AssignmentInfoCard(
      label: strings.claimAccident,
      child: accident == null
          ? AssignmentEmptyNote(message: strings.noAccidentDetailsYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssignmentInfoRow(
                  label: strings.accidentType,
                  value: strings.incidentTypeLabelFor(accident.accidentType),
                ),
                AssignmentInfoRow(
                  label: strings.accidentDate,
                  value: accident.accidentDateTime == null
                      ? accident.accidentDate
                      : ClaimDateFormatter.dayMonthYear(
                          strings,
                          accident.accidentDateTime!,
                        ),
                ),
                AssignmentInfoRow(
                  label: strings.accidentTime,
                  value: accident.accidentTime,
                ),
                AssignmentInfoRow(
                  label: strings.accidentDescription,
                  value: accident.description,
                ),
                AssignmentInfoRow(
                  label: strings.damageDescriptionLabel,
                  value: accident.damageDescription,
                ),
              ],
            ),
    );
  }

  // --- `incidentLocation` + `incidentCoordinates` -------------------------

  Widget? _reportedIncident(BuildContext context, AppStrings strings) {
    final address = claim.incidentLocation?.trim();
    final coordinates = claim.incidentCoordinates;
    final incidentPoint = claim.incidentMapPoint;
    final type = strings.incidentTypeLabelFor(claim.incidentType);
    if ((address == null || address.isEmpty) &&
        coordinates == null &&
        type == null) {
      return null;
    }

    return AssignmentInfoCard(
      label: strings.reportedIncident,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentInfoRow(label: strings.incidentTypeLabel, value: type),
          AssignmentInfoRow(label: strings.locationAddress, value: address),
          AssignmentInfoRow(
            label: strings.coordinatesLabel,
            value: coordinates?.label,
          ),
          AssignmentInfoRow(
            label: strings.capturedAtLabel,
            value: coordinates?.capturedAt == null
                ? null
                : ClaimDateFormatter.capturedAt(
                    strings,
                    coordinates!.capturedAt!,
                  ),
          ),
          // Real Google Map on `incidentCoordinates`. When the backend
          // sent no usable pair there is nothing to centre on, so the
          // card says so instead of guessing a position.
          if (incidentPoint != null)
            ClaimLocationMap(
              point: incidentPoint,
              markerId: 'incident',
              height: 150,
            )
          else if (coordinates != null)
            // Coordinates were present but outside real geographic
            // range, so they cannot be mapped.
            const ClaimLocationUnavailable(),
        ],
      ),
    );
  }

  // --- `location` ---------------------------------------------------------

  Widget? _capturedLocation(BuildContext context, AppStrings strings) {
    if (!claim.isDetailed) return null;
    final location = claim.location;
    final capturedPoint = claim.capturedMapPoint;

    return AssignmentInfoCard(
      label: strings.capturedLocation,
      child: location == null
          ? AssignmentEmptyNote(message: strings.noLocationCapturedYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssignmentInfoRow(
                  label: strings.locationAddress,
                  value: location.address,
                ),
                AssignmentInfoRow(
                  label: strings.coordinatesLabel,
                  value: location.coordinatesLabel,
                ),
                AssignmentInfoRow(
                  label: strings.capturedAtLabel,
                  value: location.capturedAt == null
                      ? null
                      : ClaimDateFormatter.capturedAt(
                          strings,
                          location.capturedAt!,
                        ),
                ),
                // The adjuster's own fix, mapped only when it carries a
                // usable coordinate pair — the backend can return an
                // address with null coordinates.
                if (capturedPoint != null)
                  ClaimLocationMap(
                    point: capturedPoint,
                    markerId: 'captured',
                    height: 150,
                  )
                else
                  ClaimLocationUnavailable(
                    message: strings.locationUnavailable,
                  ),
              ],
            ),
    );
  }

  // --- `evidence[]` -------------------------------------------------------

  Widget? _evidence(BuildContext context, AppStrings strings) {
    if (!claim.isDetailed) return null;
    final photos = claim.evidencePhotos;

    return AssignmentInfoCard(
      label: strings.claimEvidence,
      child: photos.isEmpty
          ? AssignmentEmptyNote(message: strings.noEvidenceUploadedYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.evidencePhotoCount(photos.length),
                  style: context.font14Regular?.copyWith(
                    color: context.colors.textSecondaryColor,
                    fontSize: context.width(12),
                  ),
                ),
                context.addVerticalSpace(10),
                ClaimEvidenceGallery(items: photos),
              ],
            ),
    );
  }

  // --- `signature` --------------------------------------------------------

  Widget? _signature(BuildContext context, AppStrings strings) {
    if (!claim.isDetailed) return null;
    final signature = claim.signature;

    return AssignmentInfoCard(
      label: strings.claimSignature,
      child: signature == null || !signature.hasImage
          ? AssignmentEmptyNote(message: strings.noSignatureCapturedYet)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: context.circularRadius(12),
                  child: Container(
                    height: context.height(120),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.colors.backgroundColor,
                      border: Border.all(color: context.colors.borderColor),
                      borderRadius: context.circularRadius(12),
                    ),
                    child: ClaimRemoteImage(
                      url: signature.url,
                      unavailableLabel: strings.evidenceImageUnavailable,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                context.addVerticalSpace(10),
                AssignmentInfoRow(
                  label: strings.capturedAtLabel,
                  value: signature.capturedAt == null
                      ? null
                      : ClaimDateFormatter.capturedAt(
                          strings,
                          signature.capturedAt!,
                        ),
                ),
              ],
            ),
    );
  }

  // --- `assignment` + `createdBy` -----------------------------------------

  Widget? _assignment(BuildContext context, AppStrings strings) {
    final assignedTo = claim.assignedTo?.displayName;
    final assignedBy = claim.assignedBy?.displayName;
    final createdBy = claim.createdBy?.displayName;
    if (assignedTo == null &&
        assignedBy == null &&
        createdBy == null &&
        claim.assignedAt == null &&
        claim.priority == null) {
      return null;
    }

    return AssignmentInfoCard(
      label: strings.assignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentInfoRow(label: strings.assignedTo, value: assignedTo),
          AssignmentInfoRow(label: strings.assignedBy, value: assignedBy),
          AssignmentInfoRow(
            label: strings.assignedDateLabel,
            value: claim.assignedAt == null
                ? null
                : ClaimDateFormatter.capturedAt(strings, claim.assignedAt!),
          ),
          AssignmentInfoRow(
            label: strings.priorityLabel,
            value: strings.priorityLabelFor(claim.priority),
          ),
          AssignmentInfoRow(
            label: strings.assignmentNotesLabel,
            value: claim.assignmentNotes,
          ),
          AssignmentInfoRow(label: strings.createdByLabel, value: createdBy),
          AssignmentInfoRow(
            label: strings.createdAtLabel,
            value: claim.createdAt == null
                ? null
                : ClaimDateFormatter.capturedAt(strings, claim.createdAt!),
          ),
        ],
      ),
    );
  }

  // --- correction note (read from `timeline`) -----------------------------

  Widget? _correction(BuildContext context, AppStrings strings) {
    final note = claim.correctionNote;
    if (note == null) return null;

    return AssignmentInfoCard(
      label: strings.requestedCorrection,
      child: Text(
        note,
        style: context.font16Regular?.copyWith(
          color: context.colors.textPrimaryColor,
          height: 1.4,
        ),
      ),
    );
  }

  // --- `decisionNotes` / `closedBy` / `closedAt` / `closingNotes` ---------

  Widget? _closure(BuildContext context, AppStrings strings) {
    final closedBy = claim.closedBy?.displayName;
    if (claim.decisionNotes == null &&
        closedBy == null &&
        claim.closedAt == null &&
        claim.closingNotes == null) {
      return null;
    }

    return AssignmentInfoCard(
      label: strings.claimClosure,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssignmentInfoRow(
            label: strings.decisionNotesLabel,
            value: claim.decisionNotes,
          ),
          AssignmentInfoRow(label: strings.closedByLabel, value: closedBy),
          AssignmentInfoRow(
            label: strings.closedAtLabel,
            value: claim.closedAt == null
                ? null
                : ClaimDateFormatter.capturedAt(strings, claim.closedAt!),
          ),
          AssignmentInfoRow(
            label: strings.closingNotesLabel,
            value: claim.closingNotes,
          ),
        ],
      ),
    );
  }

  // --- `timeline[]` -------------------------------------------------------

  Widget? _activity(BuildContext context, AppStrings strings) {
    if (claim.timeline.isEmpty) return null;

    return AssignmentInfoCard(
      label: strings.claimActivity,
      child: ClaimTimelineView(entries: claim.timelineLatestFirst),
    );
  }
}
