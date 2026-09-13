import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class ClaimReadyBanner extends StatelessWidget {
  const ClaimReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: success.changeOpacity(0.1),
        borderRadius: context.circularRadius(16),
        border: Border.all(color: success.changeOpacity(0.28)),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 14, horizontal: 14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: success, shape: BoxShape.circle),
              child: Padding(
                padding: context.spaceSymmetric(vertical: 6, horizontal: 6),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.cardColor,
                  size: context.width(16),
                ),
              ),
            ),
            context.addHorizontalSpace(12),
            Expanded(
              child: Text(
                strings.claimReadyToSubmit,
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
