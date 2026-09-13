import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/accident_location.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_location_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_documents_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_information_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_ready_banner.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_review_section_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';

class ClaimReviewArgs {
  const ClaimReviewArgs({required this.claimId, this.summary});

  final String claimId;
  final ClaimReviewSummary? summary;
}

class ClaimReviewScreen extends StatelessWidget {
  const ClaimReviewScreen({
    super.key,
    required this.args,
    this.onEdit,
    this.onSubmit,
  });

  final ClaimReviewArgs args;
  final ValueChanged<ClaimReviewSectionId>? onEdit;
  final ValueChanged<ClaimReviewSummary>? onSubmit;

  static const reviewWorkStep = 7;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    ClaimReviewSummary? summary,
  }) {
    return context.pushNamed(
      Routes.claimReviewScreen,
      arguments: ClaimReviewArgs(claimId: claimId, summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final summary =
        args.summary ?? ClaimReviewSummary.ready(claimId: args.claimId);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(summary.claimId),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.reviewClaim,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: context.spaceHorizontal(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        context.addVerticalSpace(4),
                        Text(
                          strings.inspectionStepIndicator(
                            ClaimReviewScreen.reviewWorkStep,
                            InspectionProgress.totalCount,
                          ),
                          style: context.font14Regular?.copyWith(
                            color: colors.primaryColor,
                            fontWeight: FontWeightHelper.medium,
                            letterSpacing: 0.2,
                          ),
                        ),
                        context.addVerticalSpace(6),
                        const InspectionStepTrack(
                          step: ClaimReviewScreen.reviewWorkStep,
                        ),
                        context.addVerticalSpace(16),
                        Text(
                          strings.claimFieldLabel,
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                            letterSpacing: 0.8,
                            fontWeight: FontWeightHelper.medium,
                          ),
                        ),
                        context.addVerticalSpace(4),
                        Text(
                          summary.claimNumber,
                          style: context.font22Bold?.copyWith(
                            color: colors.textPrimaryColor,
                            fontWeight: FontWeightHelper.bold,
                            height: 1.2,
                          ),
                        ),
                        context.addVerticalSpace(20),
                        for (final section in ClaimReviewSectionId.values) ...[
                          ClaimReviewSectionCard(
                            key: Key('review-card-${section.name}'),
                            title: _title(strings, section),
                            checks: _checks(strings, summary, section),
                            editKey: Key('review-edit-${section.name}'),
                            onEdit: () => _edit(context, summary, section),
                          ),
                          context.addVerticalSpace(12),
                        ],
                        context.addVerticalSpace(4),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: colors.cardColor,
                elevation: 8,
                shadowColor: colors.textPrimaryColor.withValues(alpha: 0.08),
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
                  child: Column(
                    children: [
                      if (summary.isReady) const ClaimReadyBanner(),
                      if (summary.isReady) context.addVerticalSpace(12),
                      AppPrimaryButton(
                        key: const Key('review-submit'),
                        label: strings.submitClaim,
                        prominent: true,
                        onPressed: summary.isReady
                            ? () => _submit(context, summary)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppStrings strings, ClaimReviewSectionId section) {
    switch (section) {
      case ClaimReviewSectionId.vehicle:
        return strings.vehicleSection;
      case ClaimReviewSectionId.customer:
        return strings.customerSection;
      case ClaimReviewSectionId.policy:
        return strings.policySection;
      case ClaimReviewSectionId.accident:
        return strings.inspectionStepLabel(InspectionStepId.accident);
      case ClaimReviewSectionId.location:
        return strings.inspectionStepLabel(InspectionStepId.location);
      case ClaimReviewSectionId.evidence:
        return strings.inspectionStepLabel(InspectionStepId.evidence);
      case ClaimReviewSectionId.documents:
        return strings.inspectionStepLabel(InspectionStepId.documents);
      case ClaimReviewSectionId.signature:
        return strings.inspectionStepLabel(InspectionStepId.signature);
    }
  }

  List<String> _checks(
    AppStrings strings,
    ClaimReviewSummary summary,
    ClaimReviewSectionId section,
  ) {
    switch (section) {
      case ClaimReviewSectionId.vehicle:
        return [summary.licensePlate, summary.makeModel];
      case ClaimReviewSectionId.customer:
        return [summary.customerName];
      case ClaimReviewSectionId.policy:
        return [summary.policyNumber, strings.policyActiveShort];
      case ClaimReviewSectionId.accident:
        return [
          strings.accidentTypeLabel(summary.accidentType),
          if (summary.accidentDateComplete) strings.accidentDate,
          if (summary.accidentTimeComplete) strings.accidentTime,
          if (summary.accidentDescriptionComplete) strings.accidentDescription,
        ];
      case ClaimReviewSectionId.location:
        return [if (summary.locationCaptured) strings.locationCaptured];
      case ClaimReviewSectionId.evidence:
        return [
          strings.reviewEvidenceCount(
            summary.evidenceCompleted,
            summary.evidenceTotal,
          ),
        ];
      case ClaimReviewSectionId.documents:
        return [
          strings.reviewDocumentsCount(
            summary.documentsCompleted,
            summary.documentsTotal,
          ),
        ];
      case ClaimReviewSectionId.signature:
        return [if (summary.signatureCompleted) strings.completedStepHint];
    }
  }

  void _edit(
    BuildContext context,
    ClaimReviewSummary summary,
    ClaimReviewSectionId section,
  ) {
    if (onEdit != null) {
      onEdit!(section);
      return;
    }

    switch (section) {
      case ClaimReviewSectionId.vehicle:
      case ClaimReviewSectionId.customer:
      case ClaimReviewSectionId.policy:
        VehicleInformationScreen.open(
          context,
          result: VehicleLookupResult.demo(
            claimId: summary.claimId,
            plateNumber: summary.licensePlate,
          ),
        );
      case ClaimReviewSectionId.accident:
        AccidentDetailsScreen.open(context, claimId: summary.claimId);
      case ClaimReviewSectionId.location:
        AccidentLocationScreen.open(
          context,
          location: AccidentLocation.demo(claimId: summary.claimId),
        );
      case ClaimReviewSectionId.evidence:
        VehicleEvidenceScreen.open(context, claimId: summary.claimId);
      case ClaimReviewSectionId.documents:
        ClaimDocumentsScreen.open(context, claimId: summary.claimId);
      case ClaimReviewSectionId.signature:
        CustomerSignatureScreen.open(context, claimId: summary.claimId);
    }
  }

  void _submit(BuildContext context, ClaimReviewSummary summary) {
    if (onSubmit != null) {
      onSubmit!(summary);
      return;
    }
    InspectionProgress.complete(summary.claimId, InspectionStepId.review);
    ClaimValidationScreen.open(context, summary: summary);
  }
}
