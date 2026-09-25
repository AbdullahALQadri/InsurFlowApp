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
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_detail_sections.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_details_illustration.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_progress_view.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_status_transition_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/start_claim_confirmation_sheet.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/inspection_navigator.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/presentation/widgets/assignment_availability_dialog.dart';
import 'package:insurflow/features/claims/presentation/widgets/decline_assignment_sheet.dart';

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
            if (state is ClaimDetailsLoadSuccess) {
              _handleAcceptanceState(context, state, strings);
            }
            if (state is ClaimDetailsLoadSuccess &&
                state.hasPromptedAcceptance &&
                !state.isAcceptingAssignment &&
                state.acceptFailure == null &&
                state.claim.status.canStart) {
              // The server moved the claim to ASSIGNED, so it is now
              // this adjuster's to inspect.
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(strings.assignmentAccepted)),
                );
            }
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
                isAccepting: state.isAcceptingAssignment,
                startError: state.startFailure == null
                    ? null
                    : strings.startMessageFor(state.startFailure!),
                acceptError: state.acceptFailure == null
                    ? null
                    : _acceptMessage(strings, state.acceptFailure!),
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

/// Offers the availability dialog for a claim awaiting acceptance, and
/// surfaces the outcome of an accept attempt.
///
/// The prompt is offered once per loaded claim: `hasPromptedAcceptance`
/// is set as soon as it is shown, so declining does not re-open it on
/// the next rebuild. The CTA remains available for a change of mind.
void _handleAcceptanceState(
  BuildContext context,
  ClaimDetailsLoadSuccess state,
  AppStrings strings,
) {
  final failure = state.acceptFailure;
  if (failure != null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(_acceptMessage(strings, failure))),
      );
    return;
  }

  if (state.claim.status.awaitsAcceptance) {
    if (state.hasPromptedAcceptance || state.isAcceptingAssignment) return;
    final bloc = context.read<ClaimDetailsBloc>();
    // Mark it offered before awaiting, so a rebuild mid-dialog cannot
    // stack a second one.
    bloc.add(const ClaimAcceptancePrompted());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      await _askAvailability(
        context,
        claimNumber: state.claim.claimNumber,
        bloc: bloc,
      );
    });
  }
}

Future<void> _askAvailability(
  BuildContext context, {
  required String? claimNumber,
  required ClaimDetailsBloc bloc,
}) async {
  final accepted = await AssignmentAvailabilityDialog.show(
    context,
    claimNumber: claimNumber,
  );
  if (!context.mounted) return;

  if (accepted) {
    bloc.add(const ClaimAssignmentAcceptRequested());
    return;
  }

  // Declining asks for the reason the backend requires, then tells the
  // officer so the claim can be reassigned. Backing out of the reason
  // sheet leaves the claim untouched.
  final reason = await DeclineAssignmentSheet.show(context);
  if (reason == null || reason.trim().isEmpty) return;
  bloc.add(ClaimAssignmentDeclineRequested(reason));
}

/// The backend answers 409 when the claim already moved on, which is a
/// different situation from a network or server problem.
String _acceptMessage(AppStrings strings, Failure failure) {
  if (failure is ValidationFailure) return strings.assignmentNoLongerPending;
  if (failure is NetworkFailure) return strings.messageFor(failure);
  return strings.assignmentAcceptFailed;
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.claim,
    required this.isStarting,
    this.startError,
    this.isAccepting = false,
    this.acceptError,
  });

  final Claim claim;
  final bool isStarting;
  final String? startError;
  final bool isAccepting;
  final String? acceptError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

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
                      '${strings.claimNumberPrefix}${claim.displayNumber}',
                      style: context.font22Bold?.copyWith(
                        color: colors.textPrimaryColor,
                        fontWeight: FontWeightHelper.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  ClaimStatusTransitionBadge(
                    key: const ValueKey('claim-status-transition'),
                    status: claim.status,
                  ),
                ],
              ),
              context.addVerticalSpace(8),
              const ClaimDetailsIllustration(),
              context.addVerticalSpace(8),
              ClaimDetailSections(claim: claim),
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
                isAccepting: isAccepting,
                acceptError: acceptError,
                claimNumber: claim.displayNumber,
                // The confirmation sheet names the vehicle; before the
                // registry lookup only the plate is known, so that is
                // what it shows.
                vehicle:
                    claim.vehicleMakeModel ??
                    claim.plateNumber ??
                    strings.notAvailable,
                isStarting: isStarting,
                startError: startError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClaimDetailsCta extends StatelessWidget {
  const _ClaimDetailsCta({
    required this.claim,
    required this.claimNumber,
    required this.vehicle,
    required this.isStarting,
    this.startError,
    this.isAccepting = false,
    this.acceptError,
  });

  final Claim claim;
  final String claimNumber;
  final String vehicle;
  final bool isStarting;
  final String? startError;
  final bool isAccepting;
  final String? acceptError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    // A claim waiting on this adjuster offers acceptance instead of the
    // locked hint; the inspection actions unlock once it is ASSIGNED.
    if (claim.status.awaitsAcceptance) {
      return Column(
        children: [
          if (acceptError != null) ...[
            Text(
              acceptError!,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.inputErrorBorderColor,
              ),
            ),
            context.addVerticalSpace(10),
          ],
          AppPrimaryButton(
            key: const Key('accept-assignment-cta'),
            label: strings.acceptAssignment,
            prominent: true,
            isLoading: isAccepting,
            onPressed: isAccepting
                ? null
                : () => _askAvailability(
                    context,
                    claimNumber: claim.claimNumber,
                    bloc: context.read<ClaimDetailsBloc>(),
                  ),
          ),
          context.addVerticalSpace(10),
          Text(
            strings.awaitingYourAcceptance,
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
