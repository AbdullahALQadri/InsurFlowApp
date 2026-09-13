import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:lottie/lottie.dart';

import 'splash_atmosphere.dart';

class SplashBrandMark extends StatelessWidget {
  const SplashBrandMark({
    super.key,
    required this.lottie,
    required this.glow,
    required this.asset,
    required this.size,
    this.onLoaded,
  });

  final AnimationController lottie;
  final Animation<double> glow;
  final String asset;
  final double size;
  final void Function(LottieComposition composition)? onLoaded;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'InsurFlow',
      image: true,
      child: SplashLogoGlow(
        glow: glow,
        size: size,
        child: Lottie.asset(
          asset,
          controller: lottie,
          onLoaded: onLoaded,
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: false,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              size: Size.square(size),
              painter: _FallbackMarkPainter(),
            );
          },
        ),
      ),
    );
  }
}

/// Static shield + check used only if the Lottie asset fails to load.
class _FallbackMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 512;
    final scaleY = size.height / 512;
    canvas.scale(scaleX, scaleY);

    final shield = Path()
      ..moveTo(256, 72)
      ..cubicTo(330, 72, 392, 104, 392, 176)
      ..cubicTo(392, 268, 336, 348, 256, 440)
      ..cubicTo(176, 348, 120, 268, 120, 176)
      ..cubicTo(120, 104, 182, 72, 256, 72)
      ..close();

    final fill = Paint()
      ..color = AppSplashColors.atmosphere.changeOpacity(0.72)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppSplashColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeJoin = StrokeJoin.round;
    final check = Paint()
      ..color = AppSplashColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shield, fill);
    canvas.drawPath(shield, stroke);

    final checkPath = Path()
      ..moveTo(172, 252)
      ..lineTo(230, 314)
      ..lineTo(354, 184);
    canvas.drawPath(checkPath, check);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
