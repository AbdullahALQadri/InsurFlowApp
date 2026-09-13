import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class AccidentHeaderIllustration extends StatelessWidget {
  const AccidentHeaderIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: context.height(88),
      width: double.infinity,
      child: CustomPaint(
        painter: _AccidentScenePainter(
          accent: colors.primaryColor,
          muted: colors.borderColor,
          fill: colors.iconBackgroundColor,
        ),
      ),
    );
  }
}

class _AccidentScenePainter extends CustomPainter {
  const _AccidentScenePainter({
    required this.accent,
    required this.muted,
    required this.fill,
  });

  final Color accent;
  final Color muted;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.72;
    canvas.drawLine(
      Offset(size.width * 0.06, y),
      Offset(size.width * 0.94, y),
      Paint()
        ..color = muted
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    _car(canvas, size, left: size.width * 0.14);
    _car(canvas, size, left: size.width * 0.52);

    final impact = Offset(size.width * 0.50, size.height * 0.46);
    final spark = Paint()
      ..color = accent.changeOpacity(0.55)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(impact.translate(-11, -7), impact.translate(11, 7), spark);
    canvas.drawLine(impact.translate(-9, 8), impact.translate(10, -6), spark);
    canvas.drawCircle(impact, 3, Paint()..color = accent.changeOpacity(0.28));
  }

  void _car(Canvas canvas, Size size, {required double left}) {
    final top = size.height * 0.28;
    final w = size.width * 0.32;
    final h = size.height * 0.38;

    final bodyFill = Paint()..color = fill;
    final bodyStroke = Paint()
      ..color = accent.changeOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top + h * 0.38, w, h * 0.42),
      const Radius.circular(8),
    );
    final cabin = Path()
      ..moveTo(left + w * 0.22, top + h * 0.4)
      ..lineTo(left + w * 0.34, top + h * 0.08)
      ..lineTo(left + w * 0.68, top + h * 0.08)
      ..lineTo(left + w * 0.82, top + h * 0.4)
      ..close();

    canvas.drawRRect(body, bodyFill);
    canvas.drawRRect(body, bodyStroke);
    canvas.drawPath(cabin, bodyFill);
    canvas.drawPath(cabin, bodyStroke);

    final wheel = Paint()
      ..color = accent.changeOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final wheelFill = Paint()..color = accent.changeOpacity(0.08);
    final radius = w * 0.09;
    for (final t in [0.22, 0.78]) {
      final center = Offset(left + w * t, top + h * 0.82);
      canvas.drawCircle(center, radius, wheelFill);
      canvas.drawCircle(center, radius, wheel);
    }
  }

  @override
  bool shouldRepaint(covariant _AccidentScenePainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.muted != muted ||
        oldDelegate.fill != fill;
  }
}
