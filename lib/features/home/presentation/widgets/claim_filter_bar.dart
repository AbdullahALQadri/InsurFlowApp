import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

class ClaimFilterBar extends StatelessWidget {
  const ClaimFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ClaimStatus? selected;
  final ValueChanged<ClaimStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final filters = <(String, ClaimStatus?, Color?)>[
      (strings.filterAll, null, context.colors.primaryColor),
      (
        strings.statusAssigned,
        ClaimStatus.assigned,
        ClaimStatusColors.assigned,
      ),
      (
        strings.statusInProgress,
        ClaimStatus.inProgress,
        ClaimStatusColors.inProgress,
      ),
      (
        strings.statusCorrection,
        ClaimStatus.correctionRequired,
        ClaimStatusColors.correctionRequired,
      ),
      (
        strings.statusSubmitted,
        ClaimStatus.submitted,
        ClaimStatusColors.submitted,
      ),
      (
        strings.statusApproved,
        ClaimStatus.approved,
        ClaimStatusColors.approved,
      ),
      (
        strings.statusRejected,
        ClaimStatus.rejected,
        ClaimStatusColors.rejected,
      ),
    ];

    return SizedBox(
      height: context.height(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => context.addHorizontalSpace(8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selected == filter.$2;
          return _FilterChip(
            label: filter.$1,
            color: filter.$3!,
            selected: isSelected,
            onTap: () => onSelected(filter.$2),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.circularRadius(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: context.spaceSymmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color.changeOpacity(0.14) : colors.cardColor,
            borderRadius: context.circularRadius(100),
            border: Border.all(
              color: selected ? color.changeOpacity(0.7) : colors.borderColor,
            ),
          ),
          child: Text(
            label,
            style: context.font14Bold?.copyWith(
              color: selected ? color : colors.textSecondaryColor,
              fontWeight: selected
                  ? FontWeightHelper.semiBold
                  : FontWeightHelper.medium,
              fontSize: context.width(12),
            ),
          ),
        ),
      ),
    );
  }
}
