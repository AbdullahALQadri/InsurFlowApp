import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';

class ClaimStatusBadge extends StatelessWidget {
  const ClaimStatusBadge({super.key, required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final color = ClaimStatusColors.of(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: color.changeOpacity(0.12),
        borderRadius: context.circularRadius(100),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 5, horizontal: 10),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeInOutCubic,
          style: (context.font14Bold ?? const TextStyle()).copyWith(
            color: color,
            fontSize: context.width(11),
            letterSpacing: 0.4,
            fontWeight: FontWeightHelper.semiBold,
            height: 1.1,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Text(
              AppStrings.of(context).statusBadgeLabel(status),
              key: ValueKey(status),
            ),
          ),
        ),
      ),
    );
  }
}
