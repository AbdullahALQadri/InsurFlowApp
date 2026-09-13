import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class ClaimsEmptyState extends StatelessWidget {
  const ClaimsEmptyState({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: context.spaceHorizontal(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAssetHelper.lottieImage(
              AppLotties.lottieEmptyClaims,
              width: context.width(160),
              height: context.width(160),
              repeat: true,
            ),
            context.addVerticalSpace(16),
            Text(
              title ?? AppStrings.of(context).noClaimsFound,
              textAlign: TextAlign.center,
              style: context.font18Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
            context.addVerticalSpace(8),
            Text(
              subtitle ?? AppStrings.of(context).noClaimsFoundHint,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
