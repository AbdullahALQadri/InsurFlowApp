import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';

class InsurFlowBrandMark extends StatelessWidget {
  const InsurFlowBrandMark({
    super.key,
    required this.size,
    this.fillColor,
    this.strokeColor,
    this.checkColor,
  });

  final double size;
  final Color? fillColor;
  final Color? strokeColor;
  final Color? checkColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'InsurFlow',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: InsurFlowMarkPainter(
          fillColor: fillColor ?? AppSplashColors.atmosphere.changeOpacity(0.72),
          strokeColor: strokeColor ?? AppSplashColors.cyan,
          checkColor: checkColor ?? AppSplashColors.textPrimary,
        ),
      ),
    );
  }
}

class InsurFlowMarkPainter extends CustomPainter {
  const InsurFlowMarkPainter({
    required this.fillColor,
    required this.strokeColor,
    required this.checkColor,
  });

  final Color fillColor;
  final Color strokeColor;
  final Color checkColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 512, size.height / 512);

    final shield = Path()
      ..moveTo(256, 72)
      ..cubicTo(330, 72, 392, 104, 392, 176)
      ..cubicTo(392, 268, 336, 348, 256, 440)
      ..cubicTo(176, 348, 120, 268, 120, 176)
      ..cubicTo(120, 104, 182, 72, 256, 72)
      ..close();

    canvas.drawPath(
      shield,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round,
    );

    final checkPath = Path()
      ..moveTo(172, 252)
      ..lineTo(230, 314)
      ..lineTo(354, 184);
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant InsurFlowMarkPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.checkColor != checkColor;
  }
}
