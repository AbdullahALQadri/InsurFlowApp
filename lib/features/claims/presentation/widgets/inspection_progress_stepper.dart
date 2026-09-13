import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_node.dart';

class InspectionProgressStepper extends StatelessWidget {
  const InspectionProgressStepper({
    super.key,
    required this.progress,
    this.onStepSelected,
  });

  final InspectionProgress progress;
  final ValueChanged<InspectionStepId>? onStepSelected;

  @override
  Widget build(BuildContext context) {
    final steps = InspectionStepId.values;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            phase: progress.phaseOf(steps[i]),
            isLast: i == steps.length - 1,
            animationDelay: Duration(milliseconds: i * 120),
            connectorFilled: i < progress.currentIndex,
            onSelected: onStepSelected,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.phase,
    required this.isLast,
    required this.animationDelay,
    required this.connectorFilled,
    this.onSelected,
  });

  final InspectionStepId step;
  final InspectionStepPhase phase;
  final bool isLast;
  final Duration animationDelay;
  final bool connectorFilled;
  final ValueChanged<InspectionStepId>? onSelected;

  static const _connectorWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final isCurrent = phase == InspectionStepPhase.current;
    final isCompleted = phase == InspectionStepPhase.completed;
    final canOpen = onSelected != null && phase != InspectionStepPhase.upcoming;

    return Semantics(
      selected: isCurrent,
      button: canOpen,
      label:
          '${strings.inspectionStepLabel(step)}. ${_phaseLabel(strings, phase)}',
      child: InkWell(
        onTap: canOpen ? () => onSelected!(step) : null,
        borderRadius: context.circularRadius(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.width(32),
              child: Column(
                children: [
                  InspectionStepNode(
                    phase: phase,
                    animationDelay: animationDelay,
                  ),
                  if (!isLast)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: _connectorWidth,
                      height: context.height(isCurrent ? 22 : 16),
                      color: connectorFilled
                          ? colors.primaryColor.changeOpacity(0.28)
                          : colors.borderColor,
                    ),
                ],
              ),
            ),
            context.addHorizontalSpace(12),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                margin: context.spaceBottom(isLast ? 0 : 2),
                padding: context.spaceSymmetric(
                  vertical: isCurrent ? 6 : 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? colors.primaryColor.changeOpacity(0.06)
                      : Colors.transparent,
                  borderRadius: context.circularRadius(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.inspectionStepLabel(step),
                      style:
                          (isCurrent
                                  ? context.font16Bold
                                  : context.font16Regular)
                              ?.copyWith(
                                color: isCurrent
                                    ? colors.textPrimaryColor
                                    : isCompleted
                                    ? colors.textPrimaryColor.changeOpacity(
                                        0.82,
                                      )
                                    : colors.textSecondaryColor,
                                fontWeight: isCurrent
                                    ? FontWeightHelper.semiBold
                                    : FontWeightHelper.regular,
                                height: 1.2,
                              ),
                    ),
                    if (isCurrent) ...[
                      context.addVerticalSpace(2),
                      Text(
                        strings.currentStepLabel,
                        style: context.font14Regular?.copyWith(
                          color: colors.primaryColor,
                          fontSize: context.width(11),
                          fontWeight: FontWeightHelper.medium,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(AppStrings strings, InspectionStepPhase phase) {
    switch (phase) {
      case InspectionStepPhase.completed:
        return strings.completedStepHint;
      case InspectionStepPhase.current:
        return strings.currentStepLabel;
      case InspectionStepPhase.upcoming:
        return strings.remainingStepHint;
    }
  }
}
