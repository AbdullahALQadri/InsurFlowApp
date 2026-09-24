import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/claim_validation_progress.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_submitted_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_validation_animation.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_validation_checks.dart';
import 'package:insurflow/features/claims/presentation/widgets/submit_claim_confirmation_sheet.dart';

class ClaimValidationArgs {
  const ClaimValidationArgs({required this.claimId, this.claimNumber});

  final String claimId;

  /// `claimNumber` from the claim payload, used only for the
  /// confirmation sheet. Null when the caller does not hold it.
  final String? claimNumber;
}

class ClaimValidationScreen extends StatefulWidget {
  const ClaimValidationScreen({
    super.key,
    required this.args,
    this.validationDuration = const Duration(milliseconds: 4200),
    this.onContinue,
  });

  final ClaimValidationArgs args;
  final Duration validationDuration;
  final ValueChanged<String>? onContinue;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    String? claimNumber,
  }) {
    return context.pushNamed(
      Routes.claimValidationScreen,
      arguments: ClaimValidationArgs(
        claimId: claimId,
        claimNumber: claimNumber,
      ),
    );
  }

  @override
  State<ClaimValidationScreen> createState() => _ClaimValidationScreenState();
}

class _ClaimValidationScreenState extends State<ClaimValidationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(
      vsync: this,
      duration: widget.validationDuration,
    );
    if (widget.validationDuration == Duration.zero) {
      _timeline.value = 1;
    } else {
      _timeline.forward();
    }
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;
    final lottieSize = context.isSmallScreen
        ? context.height(132)
        : context.height(156);
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
        key: ValueKey(widget.args.claimId),
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: context.spaceSymmetric(vertical: 4, horizontal: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textPrimaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: context.spaceHorizontal(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: AnimatedBuilder(
                            animation: _timeline,
                            builder: (context, _) {
                              final progress = ClaimValidationProgress(
                                t: _timeline.value,
                              );
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    strings.checkingYourClaim,
                                    textAlign: TextAlign.center,
                                    style: context.font22Bold?.copyWith(
                                      color: colors.textPrimaryColor,
                                      fontWeight: FontWeightHelper.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  context.addVerticalSpace(10),
                                  Text(
                                    strings.makingSureEverythingComplete,
                                    textAlign: TextAlign.center,
                                    style: context.font16Regular?.copyWith(
                                      color: colors.textSecondaryColor,
                                      height: 1.4,
                                    ),
                                  ),
                                  context.addVerticalSpace(20),
                                  ClaimValidationAnimation(size: lottieSize),
                                  context.addVerticalSpace(24),
                                  ClaimValidationChecks(progress: progress),
                                  context.addVerticalSpace(16),
                                  AnimatedOpacity(
                                    opacity: progress.showsSuccess ? 1 : 0,
                                    duration: const Duration(milliseconds: 320),
                                    child: progress.showsSuccess
                                        ? _SuccessLine(
                                            label: strings.everythingLooksGood,
                                            success: success,
                                          )
                                        : SizedBox(height: context.height(28)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Material(
                color: colors.cardColor,
                elevation: 8,
                shadowColor: colors.textPrimaryColor.withValues(alpha: 0.08),
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _timeline,
                    builder: (context, _) {
                      final ready = ClaimValidationProgress(
                        t: _timeline.value,
                      ).isComplete;
                      return AppPrimaryButton(
                        key: const Key('validation-continue'),
                        label: strings.continueToSubmit,
                        prominent: true,
                        onPressed: ready ? _continue : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (widget.onContinue != null) {
      widget.onContinue!(widget.args.claimId);
      return;
    }

    final confirmed = await SubmitClaimConfirmationSheet.show(
      context,
      // `claimNumber` when the caller carried it through; otherwise the
      // claim id, which is what the backend itself falls back to.
      claimNumber: widget.args.claimNumber ?? widget.args.claimId,
    );
    if (!mounted || confirmed != true) return;

    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.of(context);
    messenger.showSnackBar(SnackBar(content: Text(strings.submittingClaim)));

    try {
      final result = await AppDependencies.instance.submitClaimUseCase(
        widget.args.claimId,
      );
      if (!mounted) return;
      result.fold(
        (failure) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(content: Text(strings.messageFor(failure))),
          );
        },
        (_) {
          InspectionProgress.completeAll(widget.args.claimId);
          messenger.hideCurrentSnackBar();
          // The success screen carries the confirmation now, so the
          // snackbar would only compete with it.
          ClaimSubmittedScreen.open(
            context,
            claimNumber: widget.args.claimNumber,
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(strings.submitFailed)));
    }
  }
}

class _SuccessLine extends StatelessWidget {
  const _SuccessLine({required this.label, required this.success});

  final String label;
  final Color success;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final markSize = context.width(22);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: markSize,
          height: markSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: success.changeOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              size: context.width(16),
              color: success,
            ),
          ),
        ),
        context.addHorizontalSpace(8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.font16Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
