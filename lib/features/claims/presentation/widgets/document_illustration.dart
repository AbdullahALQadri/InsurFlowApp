import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';

class DocumentIllustration extends StatelessWidget {
  const DocumentIllustration({
    super.key,
    required this.type,
    required this.accent,
    required this.muted,
    required this.fill,
    required this.surface,
    this.completed = false,
  });

  final ClaimDocumentType type;
  final Color accent;
  final Color muted;
  final Color fill;
  final Color surface;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DocumentIllustrationPainter(
        type: type,
        accent: accent,
        muted: muted,
        fill: fill,
        surface: surface,
        completed: completed,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DocumentIllustrationPainter extends CustomPainter {
  const _DocumentIllustrationPainter({
    required this.type,
    required this.accent,
    required this.muted,
    required this.fill,
    required this.surface,
    required this.completed,
  });

  final ClaimDocumentType type;
  final Color accent;
  final Color muted;
  final Color fill;
  final Color surface;
  final bool completed;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ClaimDocumentType.driverLicense:
        _driverLicense(canvas, size);
      case ClaimDocumentType.nationalId:
        _nationalId(canvas, size);
      case ClaimDocumentType.policeReport:
        _policeReport(canvas, size);
      case ClaimDocumentType.other:
        _other(canvas, size);
    }
  }

  Paint get _stroke => Paint()
    ..color = accent.changeOpacity(completed ? 0.9 : 0.62)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()..color = fill;

  void _driverLicense(Canvas canvas, Size size) {
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.22,
        size.width * 0.84,
        size.height * 0.56,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(card, _fill);
    canvas.drawRRect(card, _stroke);

    final header = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.22,
        size.width * 0.84,
        size.height * 0.12,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(header, Paint()..color = accent.changeOpacity(0.16));

    final photo = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.14,
        size.height * 0.38,
        size.width * 0.22,
        size.height * 0.32,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(photo, Paint()..color = surface);
    canvas.drawRRect(photo, _stroke);

    final head = Offset(size.width * 0.25, size.height * 0.48);
    canvas.drawCircle(head, size.width * 0.05, _stroke);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.66),
        width: size.width * 0.14,
        height: size.height * 0.12,
      ),
      3.4,
      2.5,
      false,
      _stroke,
    );

    _textLines(
      canvas,
      origin: Offset(size.width * 0.42, size.height * 0.4),
      width: size.width * 0.42,
      count: 3,
    );
  }

  void _nationalId(Canvas canvas, Size size) {
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.24,
        size.width * 0.84,
        size.height * 0.52,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(card, _fill);
    canvas.drawRRect(card, _stroke);

    final chip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.34,
        size.width * 0.16,
        size.height * 0.12,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(chip, Paint()..color = accent.changeOpacity(0.22));
    canvas.drawRRect(chip, _stroke);

    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.4),
      size.width * 0.07,
      Paint()
        ..color = accent.changeOpacity(0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.4),
      size.width * 0.07,
      _stroke,
    );

    final mrzTop = size.height * 0.58;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.16, mrzTop + i * size.height * 0.045),
        Offset(size.width * 0.84, mrzTop + i * size.height * 0.045),
        Paint()
          ..color = accent.changeOpacity(0.35)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _policeReport(Canvas canvas, Size size) {
    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.12,
        size.width * 0.6,
        size.height * 0.76,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(page, _fill);
    canvas.drawRRect(page, _stroke);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.12,
        size.width * 0.6,
        size.height * 0.1,
      ),
      Paint()..color = accent.changeOpacity(0.14),
    );

    _textLines(
      canvas,
      origin: Offset(size.width * 0.28, size.height * 0.3),
      width: size.width * 0.44,
      count: 4,
    );

    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.7),
      size.width * 0.09,
      Paint()
        ..color = accent.changeOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.7),
      size.width * 0.09,
      _stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.7),
      Offset(size.width * 0.72, size.height * 0.7),
      _stroke,
    );
  }

  void _other(Canvas canvas, Size size) {
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.16,
        size.width * 0.52,
        size.height * 0.58,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(back, Paint()..color = muted.changeOpacity(0.45));
    canvas.drawRRect(back, _stroke);

    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.26,
        size.width * 0.58,
        size.height * 0.56,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(front, _fill);
    canvas.drawRRect(front, _stroke);

    final tab = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.18,
        size.width * 0.22,
        size.height * 0.1,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(tab, Paint()..color = accent.changeOpacity(0.16));
    canvas.drawRRect(tab, _stroke);

    _textLines(
      canvas,
      origin: Offset(size.width * 0.26, size.height * 0.4),
      width: size.width * 0.38,
      count: 3,
    );
  }

  void _textLines(
    Canvas canvas, {
    required Offset origin,
    required double width,
    required int count,
  }) {
    final paint = Paint()
      ..color = muted
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final y = origin.dy + i * 8;
      final lineWidth = i == count - 1 ? width * 0.62 : width;
      canvas.drawLine(
        Offset(origin.dx, y),
        Offset(origin.dx + lineWidth, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DocumentIllustrationPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.accent != accent ||
        oldDelegate.muted != muted ||
        oldDelegate.fill != fill ||
        oldDelegate.surface != surface ||
        oldDelegate.completed != completed;
  }
}
