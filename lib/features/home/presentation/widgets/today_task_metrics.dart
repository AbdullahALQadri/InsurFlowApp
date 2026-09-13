import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

class TodayTaskMetrics extends StatelessWidget {
  const TodayTaskMetrics({
    super.key,
    required this.assigned,
    required this.inProgress,
    required this.correctionRequired,
    required this.submitted,
    this.onMetricTap,
  });

  final int assigned;
  final int inProgress;
  final int correctionRequired;
  final int submitted;
  final ValueChanged<ClaimStatus>? onMetricTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.todayTasks,
          style: context.font18Bold?.copyWith(
            color: context.colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
        context.addVerticalSpace(12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: strings.statusAssigned,
                count: assigned,
                color: ClaimStatusColors.assigned,
                onTap: () => onMetricTap?.call(ClaimStatus.assigned),
              ),
            ),
            context.addHorizontalSpace(10),
            Expanded(
              child: _MetricCard(
                label: strings.statusInProgress,
                count: inProgress,
                color: ClaimStatusColors.inProgress,
                onTap: () => onMetricTap?.call(ClaimStatus.inProgress),
              ),
            ),
          ],
        ),
        context.addVerticalSpace(10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: strings.statusCorrectionRequired,
                count: correctionRequired,
                color: ClaimStatusColors.correctionRequired,
                onTap: () => onMetricTap?.call(ClaimStatus.correctionRequired),
              ),
            ),
            context.addHorizontalSpace(10),
            Expanded(
              child: _MetricCard(
                label: strings.statusSubmitted,
                count: submitted,
                color: ClaimStatusColors.submitted,
                onTap: () => onMetricTap?.call(ClaimStatus.submitted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.count,
    required this.color,
    this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.circularRadius(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(16),
            border: Border.all(color: colors.borderColor),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: context.width(4),
                  height: context.height(36),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: context.circularRadius(8),
                  ),
                ),
                context.addHorizontalSpace(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: context.font22Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.bold,
                          height: 1.1,
                        ),
                      ),
                      context.addVerticalSpace(4),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.font14Regular?.copyWith(
                          color: colors.textSecondaryColor,
                          fontSize: context.width(12),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
