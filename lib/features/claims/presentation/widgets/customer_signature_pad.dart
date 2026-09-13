import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class CustomerSignaturePad extends StatelessWidget {
  const CustomerSignaturePad({
    super.key,
    required this.strokes,
    required this.onStartStroke,
    required this.onUpdateStroke,
    required this.onEndStroke,
  });

  final List<List<Offset>> strokes;
  final ValueChanged<Offset> onStartStroke;
  final ValueChanged<Offset> onUpdateStroke;
  final VoidCallback onEndStroke;

  bool get hasInk => strokes.any((stroke) => stroke.length >= 2);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(20),
        border: Border.all(color: colors.primaryColor.changeOpacity(0.28)),
      ),
      child: ClipRRect(
        borderRadius: context.circularRadius(20),
        child: GestureDetector(
          key: const Key('signature-canvas'),
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => onStartStroke(details.localPosition),
          onPanUpdate: (details) => onUpdateStroke(details.localPosition),
          onPanEnd: (_) => onEndStroke(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _SignatureInkPainter(
                  strokes: strokes,
                  color: colors.textPrimaryColor,
                  baseline: colors.borderColor,
                ),
              ),
              if (!hasInk)
                Center(
                  child: Text(
                    strings.customerSignaturePlaceholder,
                    style: context.font16Regular?.copyWith(
                      color: colors.textSecondaryColor.changeOpacity(0.8),
                      fontWeight: FontWeightHelper.medium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureInkPainter extends CustomPainter {
  const _SignatureInkPainter({
    required this.strokes,
    required this.color,
    required this.baseline,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final Color baseline;

  static const _baselineInset = 0.18;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (1 - _baselineInset);
    canvas.drawLine(
      Offset(size.width * 0.08, y),
      Offset(size.width * 0.92, y),
      Paint()
        ..color = baseline
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.2, ink);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length - 1; i++) {
        final current = stroke[i];
        final next = stroke[i + 1];
        final mid = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
      }
      path.lineTo(stroke.last.dx, stroke.last.dy);
      canvas.drawPath(path, ink);
    }
  }

  @override
  bool shouldRepaint(covariant _SignatureInkPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.color != color ||
        oldDelegate.baseline != baseline;
  }
}
