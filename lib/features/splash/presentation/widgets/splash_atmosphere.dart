import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';

class SplashAtmosphere extends StatelessWidget {
  const SplashAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppSplashColors.navy,
            AppSplashColors.midnight,
            AppSplashColors.abyss,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.18),
                radius: 0.72,
                colors: [
                  AppSplashColors.atmosphere.changeOpacity(0.55),
                  AppSplashColors.cyanDeep.changeOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, 0.85),
                radius: 0.55,
                colors: [
                  AppSplashColors.cyan.changeOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft cyan bloom behind the logo. Intensity is driven by [glow].
class SplashLogoGlow extends StatelessWidget {
  const SplashLogoGlow({
    super.key,
    required this.glow,
    required this.size,
    required this.child,
  });

  final Animation<double> glow;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) {
        final intensity = glow.value;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppSplashColors.glow.changeOpacity(intensity * 0.55),
                blurRadius: context.width(36),
                spreadRadius: context.width(2),
              ),
              BoxShadow(
                color: AppSplashColors.cyanDeep.changeOpacity(intensity * 0.28),
                blurRadius: context.width(64),
                spreadRadius: context.width(6),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
