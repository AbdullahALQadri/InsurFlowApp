import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/api_state_views.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/location_permission_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_missing_banner.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_ready_banner.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_review_section_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_evidence_gallery.dart';

class ClaimReviewArgs {
  const ClaimReviewArgs({required this.claimId, this.summary});

  final String claimId;

  /// Supplied by tests and by callers that already hold a snapshot.
  /// When null the screen loads the claim from `GET /claims/{id}`.
  final ClaimReviewSummary? summary;
}

/// Final review before submitting the inspection.
///
/// Reads the claim back from the backend so every value shown is the
/// server's own state, not what the app believes it uploaded. That also
/// makes the Submit button agree with
/// `POST /claims/{id}/inspection/submit`, which rejects an incomplete
/// claim with `Inspection incomplete. Missing: ...`.
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
    final provided = args.summary;
    if (provided != null) {
      return _ReviewScaffold(
        summary: provided,
        onEdit: onEdit,
        onSubmit: onSubmit,
      );
    }

    return BlocProvider(
      create: (_) =>
          AppDependencies.instance.createClaimDetailsBloc()
            ..add(ClaimDetailsRequested(args.claimId)),
      child: _ReviewLoader(
        claimId: args.claimId,
        onEdit: onEdit,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _ReviewLoader extends StatelessWidget {
  const _ReviewLoader({required this.claimId, this.onEdit, this.onSubmit});

  final String claimId;
  final ValueChanged<ClaimReviewSectionId>? onEdit;
  final ValueChanged<ClaimReviewSummary>? onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocBuilder<ClaimDetailsBloc, ClaimDetailsState>(
      builder: (context, state) {
        if (state is ClaimDetailsLoadFailure) {
          return Scaffold(
            backgroundColor: context.colors.backgroundColor,
            appBar: AppBar(
              backgroundColor: context.colors.backgroundColor,
              foregroundColor: context.colors.textPrimaryColor,
              elevation: 0,
            ),
            body: ApiErrorView(
              message: strings.messageFor(state.failure),
              onRetry: () => context.read<ClaimDetailsBloc>().add(
                ClaimDetailsRequested(claimId),
              ),
            ),
          );
        }

        final claim = switch (state) {
          ClaimDetailsLoadSuccess(:final claim) => claim,
          ClaimDetailsStarted(:final claim) => claim,
          _ => null,
        };

        if (claim == null) {
          return Scaffold(
            backgroundColor: context.colors.backgroundColor,
            appBar: AppBar(
              backgroundColor: context.colors.backgroundColor,
              foregroundColor: context.colors.textPrimaryColor,
              elevation: 0,
            ),
            body: ApiLoadingView(message: strings.loadingClaimDetails),
          );
        }

        return _ReviewScaffold(
          summary: ClaimReviewSummary.fromClaim(claim),
          onEdit: onEdit,
          onSubmit: onSubmit,
          // Re-reads GET /claims/{id} after an edit, so a step the
          // adjuster just saved is not still reported as missing.
          onRefresh: () => context.read<ClaimDetailsBloc>().add(
            ClaimDetailsRequested(claimId),
          ),
        );
      },
    );
  }
}

class _ReviewScaffold extends StatelessWidget {
  const _ReviewScaffold({
    required this.summary,
    this.onEdit,
    this.onSubmit,
    this.onRefresh,
  });

  final ClaimReviewSummary summary;
  final ValueChanged<ClaimReviewSectionId>? onEdit;
  final ValueChanged<ClaimReviewSummary>? onSubmit;

  /// Called after an edit screen closes. Null when the caller supplied
  /// a fixed summary and there is nothing to re-read.
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
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
                            title: strings.reviewSectionLabel(section),
                            checks: _checks(strings, summary, section),
                            editKey: Key('review-edit-${section.name}'),
                            media: _media(context, summary, section),
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
                      if (summary.isReady)
                        const ClaimReadyBanner()
                      else
                        ClaimMissingBanner(
                          key: const Key('review-missing-banner'),
                          sections: summary.missingSections,
                        ),
                      context.addVerticalSpace(12),
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

  /// Each line is a value the backend actually holds. A section with no
  /// server-side data shows its own "not recorded yet" line rather than
  /// a placeholder value.
  List<String> _checks(
    AppStrings strings,
    ClaimReviewSummary summary,
    ClaimReviewSectionId section,
  ) {
    switch (section) {
      case ClaimReviewSectionId.vehicle:
        return [
          if (summary.licensePlate != null) summary.licensePlate!,
          if (summary.makeModel != null) summary.makeModel!,
          if (summary.vehicleYear != null) '${summary.vehicleYear}',
          if (summary.vehicleColor != null)
            strings.vehicleColorLabel(summary.vehicleColor!),
          if (!summary.vehicleLinked) strings.noVehicleDetailsYet,
        ];
      case ClaimReviewSectionId.customer:
        return [
          if (summary.customerName != null) summary.customerName!,
          if (summary.customerPhone != null) summary.customerPhone!,
        ];
      case ClaimReviewSectionId.policy:
        return [
          if (summary.policyNumber != null) summary.policyNumber!,
          if (summary.policyStatus != null)
            strings.policyStatusLabel(summary.policyStatus)!,
          if (summary.policyNumber == null) strings.noPolicyLinkedYet,
        ];
      case ClaimReviewSectionId.accident:
        return [
          if (summary.accidentType != null)
            strings.incidentTypeLabelFor(summary.accidentType)!,
          if (summary.accidentDate != null)
            _formatAccidentDate(strings, summary.accidentDate!),
          if (summary.accidentTime != null) summary.accidentTime!,
          if (summary.accidentDescription != null) summary.accidentDescription!,
          if (summary.damageDescription != null) summary.damageDescription!,
          if (!summary.hasAccident) strings.noAccidentDetailsYet,
        ];
      case ClaimReviewSectionId.location:
        return [
          if (summary.locationAddress != null) summary.locationAddress!,
          if (summary.locationCoordinates != null) summary.locationCoordinates!,
          if (!summary.hasLocation) strings.noLocationCapturedYet,
        ];
      case ClaimReviewSectionId.evidence:
        return [
          if (summary.hasEvidence)
            strings.evidencePhotoCount(summary.evidenceCount)
          else
            strings.noEvidenceUploadedYet,
        ];
      case ClaimReviewSectionId.signature:
        return [
          if (summary.signatureCaptured)
            strings.locationCaptured
          else
            strings.noSignatureCapturedYet,
        ];
    }
  }

  /// Previews of what was actually uploaded, drawn from the URLs the
  /// backend returned. Sections with nothing stored render no media at
  /// all rather than an empty frame.
  Widget? _media(
    BuildContext context,
    ClaimReviewSummary summary,
    ClaimReviewSectionId section,
  ) {
    final strings = AppStrings.of(context);

    if (section == ClaimReviewSectionId.evidence) {
      if (summary.evidenceThumbnails.isEmpty) return null;
      return SizedBox(
        key: const Key('review-evidence-thumbnails'),
        height: context.height(68),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: summary.evidenceThumbnails.length,
          separatorBuilder: (_, _) => context.addHorizontalSpace(8),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: context.circularRadius(context.radii.sm),
            child: SizedBox(
              width: context.width(84),
              child: ClaimRemoteImage(
                url: summary.evidenceThumbnails[index],
                unavailableLabel: strings.evidenceImageUnavailable,
              ),
            ),
          ),
        ),
      );
    }

    if (section == ClaimReviewSectionId.signature) {
      final url = summary.signatureUrl;
      if (url == null || url.isEmpty) return null;
      return Container(
        key: const Key('review-signature-preview'),
        height: context.height(80),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.backgroundColor,
          borderRadius: context.circularRadius(context.radii.sm),
          border: Border.all(color: context.colors.borderColor),
        ),
        child: ClaimRemoteImage(
          url: url,
          unavailableLabel: strings.evidenceImageUnavailable,
          fit: BoxFit.contain,
        ),
      );
    }

    return null;
  }

  /// `accidentDate` arrives as `YYYY-MM-DD`; anything unparseable is
  /// shown exactly as the backend sent it.
  String _formatAccidentDate(AppStrings strings, String raw) {
    final parsed = DateTime.tryParse(raw);
    return parsed == null
        ? raw
        : ClaimDateFormatter.dayMonthYear(strings, parsed);
  }

  /// Opens the step's own screen and re-reads the claim when it closes.
  ///
  /// The edit screens write straight to the backend, so without the
  /// re-read the review would keep showing the snapshot it loaded on
  /// entry — reporting a step as missing right after it was saved.
  Future<void> _edit(
    BuildContext context,
    ClaimReviewSummary summary,
    ClaimReviewSectionId section,
  ) async {
    if (onEdit != null) {
      onEdit!(section);
      return;
    }

    final claimId = summary.claimId;
    switch (section) {
      case ClaimReviewSectionId.vehicle:
      case ClaimReviewSectionId.customer:
      case ClaimReviewSectionId.policy:
        // Vehicle, customer and policy are all written by the single
        // `PUT /claims/{id}/vehicle` call, so editing any of them means
        // re-running the plate capture and lookup.
        await VehicleIdentificationScreen.open(context, claimId: claimId);
      case ClaimReviewSectionId.accident:
        await AccidentDetailsScreen.open(context, claimId: claimId);
      case ClaimReviewSectionId.location:
        await LocationPermissionScreen.open(context, claimId: claimId);
      case ClaimReviewSectionId.evidence:
        await VehicleEvidenceScreen.open(context, claimId: claimId);
      case ClaimReviewSectionId.signature:
        await CustomerSignatureScreen.open(context, claimId: claimId);
    }

    if (!context.mounted) return;
    onRefresh?.call();
  }

  void _submit(BuildContext context, ClaimReviewSummary summary) {
    if (onSubmit != null) {
      onSubmit!(summary);
      return;
    }
    InspectionProgress.complete(summary.claimId, InspectionStepId.review);
    ClaimValidationScreen.open(
      context,
      claimId: summary.claimId,
      claimNumber: summary.claimNumber,
    );
  }
}
