import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';

class EvidenceCategoryPreview extends StatelessWidget {
  const EvidenceCategoryPreview({
    super.key,
    required this.category,
    required this.accent,
    required this.muted,
    required this.fill,
    required this.plate,
    this.completed = false,
  });

  final EvidenceCategory category;
  final Color accent;
  final Color muted;
  final Color fill;
  final Color plate;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EvidencePreviewPainter(
        category: category,
        accent: accent,
        muted: muted,
        fill: fill,
        plate: plate,
        completed: completed,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _EvidencePreviewPainter extends CustomPainter {
  const _EvidencePreviewPainter({
    required this.category,
    required this.accent,
    required this.muted,
    required this.fill,
    required this.plate,
    required this.completed,
  });

  final EvidenceCategory category;
  final Color accent;
  final Color muted;
  final Color fill;
  final Color plate;
  final bool completed;

  @override
  void paint(Canvas canvas, Size size) {
    _horizon(canvas, size);
    switch (category) {
      case EvidenceCategory.licensePlate:
        _licensePlate(canvas, size);
      case EvidenceCategory.front:
        _front(canvas, size);
      case EvidenceCategory.rear:
        _rear(canvas, size);
      case EvidenceCategory.leftSide:
        _side(canvas, size, mirrored: false);
      case EvidenceCategory.rightSide:
        _side(canvas, size, mirrored: true);
      case EvidenceCategory.damageCloseUp:
        _damage(canvas, size);
      case EvidenceCategory.accidentScene:
        _scene(canvas, size);
    }
  }

  Paint get _stroke => Paint()
    ..color = accent.changeOpacity(completed ? 0.85 : 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _body => Paint()..color = fill;

  void _horizon(Canvas canvas, Size size) {
    final y = size.height * 0.72;
    canvas.drawLine(
      Offset(size.width * 0.08, y),
      Offset(size.width * 0.92, y),
      Paint()
        ..color = muted
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
  }

  void _licensePlate(Canvas canvas, Size size) {
    final bumper = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.42,
        size.width * 0.76,
        size.height * 0.22,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bumper, _body);
    canvas.drawRRect(bumper, _stroke);

    final plateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.53),
        width: size.width * 0.52,
        height: size.height * 0.16,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(plateRect, Paint()..color = plate);
    canvas.drawRRect(
      plateRect,
      Paint()
        ..color = accent.changeOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final dash = Paint()
      ..color = accent.changeOpacity(0.45)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final cy = size.height * 0.53;
    canvas.drawLine(
      Offset(size.width * 0.34, cy),
      Offset(size.width * 0.44, cy),
      dash,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, cy),
      Offset(size.width * 0.66, cy),
      dash,
    );
  }

  void _front(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * 0.18, size.height * 0.68)
      ..lineTo(size.width * 0.22, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.28,
        size.width * 0.78,
        size.height * 0.46,
      )
      ..lineTo(size.width * 0.82, size.height * 0.68)
      ..close();
    canvas.drawPath(body, _body);
    canvas.drawPath(body, _stroke);

    _lamp(canvas, Offset(size.width * 0.32, size.height * 0.52));
    _lamp(canvas, Offset(size.width * 0.68, size.height * 0.52));

    final grille = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.56),
        width: size.width * 0.22,
        height: size.height * 0.07,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(grille, Paint()..color = muted.changeOpacity(0.7));

    final plateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.64),
        width: size.width * 0.2,
        height: size.height * 0.055,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(plateRect, Paint()..color = plate);
  }

  void _rear(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * 0.16, size.height * 0.68)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.84, size.height * 0.68)
      ..close();
    canvas.drawPath(body, _body);
    canvas.drawPath(body, _stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.22,
          size.height * 0.38,
          size.width * 0.56,
          size.height * 0.14,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = muted.changeOpacity(0.55),
    );

    _lamp(canvas, Offset(size.width * 0.3, size.height * 0.56), rear: true);
    _lamp(canvas, Offset(size.width * 0.7, size.height * 0.56), rear: true);

    final plateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.22,
        height: size.height * 0.06,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(plateRect, Paint()..color = plate);
  }

  void _side(Canvas canvas, Size size, {required bool mirrored}) {
    if (mirrored) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final body = Path()
      ..moveTo(size.width * 0.12, size.height * 0.62)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.5,
        size.width * 0.22,
        size.height * 0.46,
        size.width * 0.34,
        size.height * 0.46,
      )
      ..cubicTo(
        size.width * 0.44,
        size.height * 0.34,
        size.width * 0.62,
        size.height * 0.34,
        size.width * 0.72,
        size.height * 0.46,
      )
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.48,
        size.width * 0.9,
        size.height * 0.54,
        size.width * 0.9,
        size.height * 0.62,
      )
      ..close();
    canvas.drawPath(body, _body);
    canvas.drawPath(body, _stroke);

    final cabin = Path()
      ..moveTo(size.width * 0.38, size.height * 0.46)
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.36,
        size.width * 0.6,
        size.height * 0.36,
        size.width * 0.68,
        size.height * 0.46,
      );
    canvas.drawPath(cabin, _stroke);

    _wheel(canvas, Offset(size.width * 0.3, size.height * 0.64), size.width);
    _wheel(canvas, Offset(size.width * 0.74, size.height * 0.64), size.width);

    if (mirrored) canvas.restore();
  }

  void _damage(Canvas canvas, Size size) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.22,
        size.width * 0.68,
        size.height * 0.5,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(panel, _body);
    canvas.drawRRect(panel, _stroke);

    final crack = Paint()
      ..color = accent.changeOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final origin = Offset(size.width * 0.52, size.height * 0.4);
    canvas.drawCircle(
      origin,
      size.width * 0.045,
      Paint()..color = accent.changeOpacity(0.16),
    );
    canvas.drawLine(origin, origin.translate(-18, -14), crack);
    canvas.drawLine(origin, origin.translate(16, -10), crack);
    canvas.drawLine(origin, origin.translate(-8, 16), crack);
    canvas.drawLine(origin, origin.translate(18, 12), crack);
    canvas.drawCircle(origin, 2.4, Paint()..color = accent);
  }

  void _scene(Canvas canvas, Size size) {
    _miniCar(canvas, size, left: size.width * 0.12, scale: 0.42);
    _miniCar(canvas, size, left: size.width * 0.5, scale: 0.42);
    final impact = Offset(size.width * 0.5, size.height * 0.46);
    final spark = Paint()
      ..color = accent.changeOpacity(0.7)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(impact.translate(-10, -6), impact.translate(10, 6), spark);
    canvas.drawLine(impact.translate(-8, 7), impact.translate(9, -5), spark);
  }

  void _miniCar(
    Canvas canvas,
    Size size, {
    required double left,
    required double scale,
  }) {
    final w = size.width * scale;
    final h = size.height * 0.36;
    final top = size.height * 0.32;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top + h * 0.28, w, h * 0.5),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, _body);
    canvas.drawRRect(body, _stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.18, top, w * 0.58, h * 0.36),
        const Radius.circular(5),
      ),
      _stroke,
    );
  }

  void _lamp(Canvas canvas, Offset center, {bool rear = false}) {
    final color = rear ? accent.changeOpacity(0.55) : plate;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 16, height: 8),
        const Radius.circular(3),
      ),
      Paint()..color = color,
    );
  }

  void _wheel(Canvas canvas, Offset center, double width) {
    final radius = width * 0.055;
    canvas.drawCircle(center, radius, Paint()..color = fill);
    canvas.drawCircle(center, radius, _stroke);
  }

  @override
  bool shouldRepaint(covariant _EvidencePreviewPainter oldDelegate) {
    return oldDelegate.category != category ||
        oldDelegate.accent != accent ||
        oldDelegate.muted != muted ||
        oldDelegate.fill != fill ||
        oldDelegate.plate != plate ||
        oldDelegate.completed != completed;
  }
}
