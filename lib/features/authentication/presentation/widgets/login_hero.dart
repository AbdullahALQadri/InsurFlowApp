import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/widgets/insurflow_brand_mark.dart';
import 'package:insurflow/features/authentication/presentation/widgets/login_inspection_illustration.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    final height = context.isSmallScreen
        ? context.height(188)
        : context.height(228);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppSplashColors.navy,
              AppSplashColors.midnight,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.15, 0.2),
                  radius: 0.9,
                  colors: [
                    AppSplashColors.atmosphere.changeOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const IgnorePointer(
              child: CustomPaint(
                painter: LoginInspectionPainter(),
                child: SizedBox.expand(),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: context.spaceSymmetric(vertical: 16, horizontal: 24),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Row(
                    children: [
                      InsurFlowBrandMark(size: context.width(36)),
                      context.addHorizontalSpace(10),
                      Text(
                        'InsurFlow',
                        style: context.font18Bold?.copyWith(
                          color: AppSplashColors.textPrimary,
                          letterSpacing: 0.6,
                          fontWeight: FontWeightHelper.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
