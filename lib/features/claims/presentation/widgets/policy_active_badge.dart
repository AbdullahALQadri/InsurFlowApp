import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_schemes.dart';

class PolicyActiveBadge extends StatelessWidget {
  const PolicyActiveBadge({super.key, required this.label});

  final String label;

  /// The same tone the app uses for an approved claim, so an active
  /// policy and an approved claim read alike.
  static const fill = ClaimStatusColors.approved;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: context.circularRadius(100),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 6, horizontal: 12),
        child: Text(
          label,
          style: context.font14Bold?.copyWith(
            color: AppColorSchemes.onColorFor(fill),
            fontSize: context.width(11),
            letterSpacing: 0.8,
            fontWeight: FontWeightHelper.bold,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
