import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_status_badge.dart';

class AssignmentHeader extends StatelessWidget {
  const AssignmentHeader({super.key, required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppSplashColors.navy, AppSplashColors.midnight],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    AppSplashColors.atmosphere.changeOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
              child: Column(
                children: [
                  AppAssetHelper.lottieImage(
                    AppLotties.lottieAssignmentNotice,
                    width: context.width(112),
                    height: context.width(112),
                    repeat: true,
                  ),
                  Text(
                    AppStrings.of(context).newAssignment,
                    style: context.font22Bold?.copyWith(
                      color: AppSplashColors.textPrimary,
                      fontWeight: FontWeightHelper.bold,
                    ),
                  ),
                  context.addVerticalSpace(8),
                  Text(
                    claim.displayNumber,
                    style: context.font18Bold?.copyWith(
                      color: AppSplashColors.cyan,
                      letterSpacing: 0.4,
                      fontWeight: FontWeightHelper.semiBold,
                    ),
                  ),
                  context.addVerticalSpace(10),
                  ClaimStatusBadge(status: claim.status),
                  context.addVerticalSpace(14),
                  Text(
                    AppStrings.of(context).assignedTaskMessage,
                    textAlign: TextAlign.center,
                    style: context.font14Regular?.copyWith(
                      color: AppSplashColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  context.addVerticalSpace(8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
