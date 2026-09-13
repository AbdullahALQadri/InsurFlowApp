import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class SignaturePenIllustration extends StatelessWidget {
  const SignaturePenIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      painter: _SignaturePenPainter(
        accent: colors.primaryColor,
        muted: colors.borderColor,
        fill: colors.iconBackgroundColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SignaturePenPainter extends CustomPainter {
  const _SignaturePenPainter({
    required this.accent,
    required this.muted,
    required this.fill,
  });

  final Color accent;
  final Color muted;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.14,
        size.width * 0.38,
        size.height * 0.72,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(page, Paint()..color = fill);
    canvas.drawRRect(
      page,
      Paint()
        ..color = accent.changeOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    final linePaint = Paint()
      ..color = muted
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.32 + i * 0.12);
      canvas.drawLine(
        Offset(size.width * 0.34, y),
        Offset(size.width * 0.58, y),
        linePaint,
      );
    }

    final pen = Path()
      ..moveTo(size.width * 0.62, size.height * 0.22)
      ..lineTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.72, size.height * 0.58)
      ..lineTo(size.width * 0.66, size.height * 0.56)
      ..close();
    canvas.drawPath(pen, Paint()..color = fill);
    canvas.drawPath(
      pen,
      Paint()
        ..color = accent.changeOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final nib = Path()
      ..moveTo(size.width * 0.68, size.height * 0.56)
      ..lineTo(size.width * 0.64, size.height * 0.78)
      ..lineTo(size.width * 0.74, size.height * 0.58)
      ..close();
    canvas.drawPath(
      nib,
      Paint()
        ..color = accent.changeOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SignaturePenPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.muted != muted ||
        oldDelegate.fill != fill;
  }
}
