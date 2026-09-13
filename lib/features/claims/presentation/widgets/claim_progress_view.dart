import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/utils/inspection_navigator.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_status_transition_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_progress_stepper.dart';

class ClaimProgressView extends StatelessWidget {
  const ClaimProgressView({
    super.key,
    required this.claim,
    this.progress,
    this.embedded = false,
  });

  final Claim claim;
  final InspectionProgress? progress;
  final bool embedded;

  InspectionProgress get _progress =>
      progress ?? InspectionProgress.forClaim(claim);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final content = <Widget>[
      if (!embedded) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                claim.displayNumber,
                style: context.font22Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.bold,
                  height: 1.2,
                ),
              ),
            ),
            ClaimStatusTransitionBadge(status: claim.status),
          ],
        ),
        context.addVerticalSpace(10),
      ],
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: Text(
          strings.inspectionStepCompletedMessage(_progress.lastCompletedStep),
          key: ValueKey(_progress.lastCompletedStep),
          style: context.font16Regular?.copyWith(
            color: colors.textSecondaryColor,
            height: 1.4,
          ),
        ),
      ),
      context.addVerticalSpace(16),
      _ProgressMeter(
        completed: _progress.completedCount,
        total: InspectionProgress.totalCount,
      ),
      context.addVerticalSpace(20),
      InspectionProgressStepper(
        progress: _progress,
        onStepSelected: claim.status.canEditInspection
            ? (step) => InspectionNavigator.openStep(
                context,
                claimId: claim.id,
                step: step,
              )
            : null,
      ),
    ];

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      );
    }

    return ListView(
      padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
      children: [...content, context.addVerticalSpace(24)],
    );
  }
}

class _ProgressMeter extends StatelessWidget {
  const _ProgressMeter({required this.completed, required this.total});

  final int completed;
  final int total;

  static const _trackHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final factor = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.inspectionProgressCount(completed, total),
          style: context.font14Regular?.copyWith(
            color: colors.textSecondaryColor,
            fontWeight: FontWeightHelper.medium,
          ),
        ),
        context.addVerticalSpace(8),
        ClipRRect(
          borderRadius: context.circularRadius(100),
          child: SizedBox(
            width: double.infinity,
            height: context.height(_trackHeight),
            child: ColoredBox(
              color: colors.borderColor,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: factor),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: value.clamp(0, 1),
                    heightFactor: 1,
                    child: ColoredBox(color: colors.primaryColor),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
