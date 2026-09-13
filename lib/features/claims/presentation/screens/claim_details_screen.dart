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
import 'package:insurflow/features/claims/domain/claim_assignment.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_map_preview.dart';
import 'package:insurflow/features/claims/presentation/widgets/assignment_info_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_details_illustration.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_progress_view.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_status_transition_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/start_claim_confirmation_sheet.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/inspection_navigator.dart';

class ClaimDetailsScreen extends StatelessWidget {
  const ClaimDetailsScreen({super.key, required this.claimId});

  final String claimId;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(Routes.claimDetailsScreen, arguments: claimId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AppDependencies.instance.createClaimDetailsBloc()
            ..add(ClaimDetailsRequested(claimId)),
      child: _ClaimDetailsView(claimId: claimId),
    );
  }
}

class _ClaimDetailsView extends StatelessWidget {
  const _ClaimDetailsView({required this.claimId});

  final String claimId;

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
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: BlocBuilder<ClaimDetailsBloc, ClaimDetailsState>(
            builder: (context, state) {
              final inspecting = switch (state) {
                ClaimDetailsLoadSuccess(:final claim) =>
                  claim.status.showsInspectionProgress,
                ClaimDetailsStarted(:final claim) =>
                  claim.status.showsInspectionProgress,
                _ => false,
              };
              return Text(
                inspecting ? strings.inspectionProgress : strings.claimDetails,
                style: context.font18Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              );
            },
          ),
        ),
        body: BlocConsumer<ClaimDetailsBloc, ClaimDetailsState>(
          listener: (context, state) {
            if (state is ClaimDetailsStarted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(strings.claimStarted)));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                VehicleIdentificationScreen.open(
                  context,
                  claimId: state.claim.id,
                );
              });
            }
          },
          builder: (context, state) {
            if (state is ClaimDetailsLoadInProgress ||
                state is ClaimDetailsInitial) {
              return ApiLoadingView(message: strings.loadingClaimDetails);
            }
            if (state is ClaimDetailsLoadFailure) {
              return ApiErrorView(
                message: strings.messageFor(state.failure),
                onRetry: () => context.read<ClaimDetailsBloc>().add(
                  ClaimDetailsRequested(claimId),
                ),
              );
            }
            if (state is ClaimDetailsLoadSuccess) {
              return _DetailsBody(
                claim: state.claim,
                isStarting: state.isStarting,
                startError: state.startFailure == null
                    ? null
                    : strings.startMessageFor(state.startFailure!),
              );
            }
            if (state is ClaimDetailsStarted) {
              return _DetailsBody(claim: state.claim, isStarting: false);
            }
            return ApiEmptyView(message: strings.unableToLoadClaim);
          },
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.claim,
    required this.isStarting,
    this.startError,
  });

  final Claim claim;
  final bool isStarting;
  final String? startError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final data = ClaimAssignment.fromClaim(claim);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${strings.claimNumberPrefix}${data.claimId}',
                      style: context.font22Bold?.copyWith(
                        color: colors.textPrimaryColor,
                        fontWeight: FontWeightHelper.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  ClaimStatusTransitionBadge(
                    key: const ValueKey('claim-status-transition'),
                    status: data.status,
                  ),
                ],
              ),
              context.addVerticalSpace(8),
              const ClaimDetailsIllustration(),
              context.addVerticalSpace(8),
              AssignmentInfoCard(
                label: strings.customer,
                child: AssignmentInfoLines(
                  lines: [
                    _value(context, data.customerName),
                    _value(context, data.customerPhone),
                  ],
                ),
              ),
              context.addVerticalSpace(12),
              AssignmentInfoCard(
                label: strings.vehicle,
                child: AssignmentInfoLines(
                  lines: [
                    _value(context, data.vehicle),
                    _value(context, data.licensePlate),
                  ],
                ),
              ),
              context.addVerticalSpace(12),
              AssignmentInfoCard(
                label: strings.location,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AssignmentInfoLines(
                      lines: [
                        _value(context, data.street),
                        _value(context, data.city),
                      ],
                    ),
                    context.addVerticalSpace(12),
                    const AccidentMapPreview(height: 108),
                  ],
                ),
              ),
              context.addVerticalSpace(12),
              AssignmentInfoCard(
                label: strings.assignment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.assignedBy,
                      style: context.font14Regular?.copyWith(
                        color: colors.textSecondaryColor,
                      ),
                    ),
                    context.addVerticalSpace(2),
                    Text(
                      _value(context, data.assignedBy),
                      style: context.font16Bold?.copyWith(
                        color: colors.textPrimaryColor,
                      ),
                    ),
                    context.addVerticalSpace(12),
                    Text(
                      strings.assignedDateLabel,
                      style: context.font14Regular?.copyWith(
                        color: colors.textSecondaryColor,
                      ),
                    ),
                    context.addVerticalSpace(2),
                    Text(
                      ClaimDateFormatter.assignedOn(data.assignedAt),
                      style: context.font16Bold?.copyWith(
                        color: colors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (claim.status == ClaimStatus.correctionRequired &&
                  (claim.notes?.trim().isNotEmpty ?? false)) ...[
                context.addVerticalSpace(12),
                AssignmentInfoCard(
                  label: strings.requestedCorrection,
                  child: Text(
                    claim.notes!.trim(),
                    style: context.font16Regular?.copyWith(
                      color: colors.textPrimaryColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              if (claim.status.showsInspectionProgress) ...[
                context.addVerticalSpace(16),
                ClaimProgressView(claim: claim, embedded: true),
              ],
              context.addVerticalSpace(16),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardColor,
            border: Border(top: BorderSide(color: colors.borderColor)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
              child: _ClaimDetailsCta(
                claim: claim,
                claimNumber: data.claimId,
                vehicle: _value(context, data.vehicle),
                isStarting: isStarting,
                startError: startError,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _value(BuildContext context, String value) {
    if (value.trim().isEmpty) return AppStrings.of(context).notAvailable;
    return value;
  }
}

class _ClaimDetailsCta extends StatelessWidget {
  const _ClaimDetailsCta({
    required this.claim,
    required this.claimNumber,
    required this.vehicle,
    required this.isStarting,
    this.startError,
  });

  final Claim claim;
  final String claimNumber;
  final String vehicle;
  final bool isStarting;
  final String? startError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    if (claim.status.canStart) {
      return Column(
        children: [
          if (startError != null) ...[
            Text(
              startError!,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.inputErrorBorderColor,
              ),
            ),
            context.addVerticalSpace(10),
          ],
          AppPrimaryButton(
            key: const Key('start-claim-cta'),
            label: strings.startClaim,
            prominent: true,
            isLoading: isStarting,
            onPressed: isStarting
                ? null
                : () => StartClaimConfirmationSheet.show(
                    context,
                    claimNumber: claimNumber,
                    vehicle: vehicle,
                  ),
          ),
          context.addVerticalSpace(10),
          Text(
            strings.startClaimHint,
            textAlign: TextAlign.center,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
              height: 1.35,
              fontSize: context.width(12),
            ),
          ),
        ],
      );
    }

    if (claim.status.canContinueInspection) {
      return Column(
        children: [
          AppPrimaryButton(
            key: const Key('continue-inspection-cta'),
            label: claim.status == ClaimStatus.correctionRequired
                ? strings.fixCorrection
                : strings.continueInspection,
            prominent: true,
            onPressed: () =>
                InspectionNavigator.openCurrent(context, claimId: claim.id),
          ),
        ],
      );
    }

    return Text(
      strings.claimLockedHint,
      textAlign: TextAlign.center,
      style: context.font14Regular?.copyWith(
        color: colors.textSecondaryColor,
        height: 1.4,
      ),
    );
  }
}
