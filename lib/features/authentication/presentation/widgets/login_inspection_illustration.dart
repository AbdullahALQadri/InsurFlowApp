import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';

/// Abstract automotive inspection + shield/workflow backdrop.
/// Intentionally quiet so it never competes with the logo or form.
class LoginInspectionPainter extends CustomPainter {
  const LoginInspectionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.006
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final soft = Paint()
      ..color = AppSplashColors.line.changeOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.0045
      ..strokeCap = StrokeCap.round;

    final node = Paint()
      ..color = AppSplashColors.glow.changeOpacity(0.22)
      ..style = PaintingStyle.fill;

    _drawInspectionFrame(canvas, size, stroke);
    _drawVehicle(canvas, size, stroke);
    _drawShield(canvas, size, stroke);
    _drawWorkflow(canvas, size, soft, node);
  }

  void _drawInspectionFrame(Canvas canvas, Size size, Paint paint) {
    final inset = size.width * 0.08;
    final length = size.width * 0.12;
    final rect = Rect.fromLTWH(
      inset,
      size.height * 0.22,
      size.width - inset * 2,
      size.height * 0.62,
    );

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * length, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy * length), paint);
    }

    corner(rect.topLeft, 1, 1);
    corner(rect.topRight, -1, 1);
    corner(rect.bottomLeft, 1, -1);
    corner(rect.bottomRight, -1, -1);
  }

  void _drawVehicle(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.18, h * 0.62)
      ..cubicTo(w * 0.2, h * 0.52, w * 0.28, h * 0.46, w * 0.4, h * 0.45)
      ..cubicTo(w * 0.48, h * 0.36, w * 0.6, h * 0.36, w * 0.68, h * 0.46)
      ..cubicTo(w * 0.8, h * 0.48, w * 0.86, h * 0.54, w * 0.88, h * 0.62)
      ..lineTo(w * 0.18, h * 0.62)
      ..close();

    canvas.drawPath(path, paint);

    final cabin = Path()
      ..moveTo(w * 0.4, h * 0.46)
      ..cubicTo(w * 0.46, h * 0.38, w * 0.58, h * 0.38, w * 0.66, h * 0.47);
    canvas.drawPath(cabin, paint);

    final wheelRadius = w * 0.035;
    canvas.drawCircle(Offset(w * 0.32, h * 0.64), wheelRadius, paint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.64), wheelRadius, paint);
  }

  void _drawShield(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final shield = Path()
      ..moveTo(w * 0.78, h * 0.28)
      ..cubicTo(w * 0.86, h * 0.28, w * 0.92, h * 0.32, w * 0.92, h * 0.4)
      ..cubicTo(w * 0.92, h * 0.5, w * 0.86, h * 0.58, w * 0.78, h * 0.64)
      ..cubicTo(w * 0.7, h * 0.58, w * 0.64, h * 0.5, w * 0.64, h * 0.4)
      ..cubicTo(w * 0.64, h * 0.32, w * 0.7, h * 0.28, w * 0.78, h * 0.28)
      ..close();
    canvas.drawPath(shield, paint);

    final check = Path()
      ..moveTo(w * 0.72, h * 0.44)
      ..lineTo(w * 0.77, h * 0.5)
      ..lineTo(w * 0.86, h * 0.38);
    canvas.drawPath(check, paint);
  }

  void _drawWorkflow(Canvas canvas, Size size, Paint line, Paint node) {
    final w = size.width;
    final h = size.height;
    final a = Offset(w * 0.16, h * 0.34);
    final b = Offset(w * 0.28, h * 0.3);
    final c = Offset(w * 0.4, h * 0.34);

    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(w * 0.22, h * 0.24, b.dx, b.dy)
      ..quadraticBezierTo(w * 0.34, h * 0.4, c.dx, c.dy);
    canvas.drawPath(path, line);

    final radius = w * 0.012;
    canvas.drawCircle(a, radius, node);
    canvas.drawCircle(b, radius, node);
    canvas.drawCircle(c, radius, node);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
