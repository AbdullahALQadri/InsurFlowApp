import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class VehicleScanIllustration extends StatefulWidget {
  const VehicleScanIllustration({super.key});

  @override
  State<VehicleScanIllustration> createState() =>
      _VehicleScanIllustrationState();
}

class _VehicleScanIllustrationState extends State<VehicleScanIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _scan, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return CustomPaint(
          painter: _VehicleScanPainter(
            progress: _t.value,
            accent: colors.primaryColor,
            muted: colors.borderColor,
            fill: colors.iconBackgroundColor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _VehicleScanPainter extends CustomPainter {
  const _VehicleScanPainter({
    required this.progress,
    required this.accent,
    required this.muted,
    required this.fill,
  });

  final double progress;
  final Color accent;
  final Color muted;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.14,
      size.width * 0.76,
      size.height * 0.72,
    );

    _drawFrame(canvas, frame);
    _drawVehicle(canvas, size, frame);
    _drawScanLine(canvas, frame);
  }

  void _drawFrame(Canvas canvas, Rect frame) {
    const cornerFraction = 0.16;
    final length = frame.shortestSide * cornerFraction;
    final paint = Paint()
      ..color = accent.changeOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * length, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy * length), paint);
    }

    corner(frame.topLeft, 1, 1);
    corner(frame.topRight, -1, 1);
    corner(frame.bottomLeft, 1, -1);
    corner(frame.bottomRight, -1, -1);
  }

  void _drawVehicle(Canvas canvas, Size size, Rect frame) {
    final w = size.width;
    final h = size.height;

    final bodyFill = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final bodyStroke = Paint()
      ..color = accent.changeOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(w * 0.18, h * 0.62)
      ..cubicTo(w * 0.2, h * 0.54, w * 0.26, h * 0.5, w * 0.36, h * 0.49)
      ..cubicTo(w * 0.44, h * 0.4, w * 0.58, h * 0.39, w * 0.66, h * 0.5)
      ..cubicTo(w * 0.78, h * 0.51, w * 0.84, h * 0.55, w * 0.86, h * 0.62)
      ..lineTo(w * 0.18, h * 0.62)
      ..close();

    canvas.drawPath(body, bodyFill);
    canvas.drawPath(body, bodyStroke);

    final cabin = Path()
      ..moveTo(w * 0.38, h * 0.5)
      ..cubicTo(w * 0.44, h * 0.42, w * 0.56, h * 0.42, w * 0.64, h * 0.5);
    canvas.drawPath(cabin, bodyStroke);

    final wheel = Paint()
      ..color = accent.changeOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final wheelFill = Paint()
      ..color = accent.changeOpacity(0.08)
      ..style = PaintingStyle.fill;
    final radius = w * 0.038;
    for (final cx in [w * 0.3, w * 0.72]) {
      final center = Offset(cx, h * 0.64);
      canvas.drawCircle(center, radius, wheelFill);
      canvas.drawCircle(center, radius, wheel);
    }

    final plate = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.58),
        width: w * 0.22,
        height: h * 0.055,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(plate, Paint()..color = Colors.white);
    canvas.drawRRect(
      plate,
      Paint()
        ..color = accent.changeOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _drawScanLine(Canvas canvas, Rect frame) {
    final inset = frame.height * 0.12;
    final top = frame.top + inset;
    final bottom = frame.bottom - inset;
    final y = top + (bottom - top) * progress;

    final band = Rect.fromLTWH(frame.left, y - 7, frame.width, 14);
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.changeOpacity(0),
          accent.changeOpacity(0.14),
          accent.changeOpacity(0),
        ],
      ).createShader(band);
    canvas.drawRect(band, glow);

    final line = Paint()
      ..color = accent.changeOpacity(0.85)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(frame.left + 8, y),
      Offset(frame.right - 8, y),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _VehicleScanPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.muted != muted ||
        oldDelegate.fill != fill;
  }
}
