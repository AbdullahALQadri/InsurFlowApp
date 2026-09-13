import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';

class AccidentMapPreview extends StatelessWidget {
  const AccidentMapPreview({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.circularRadius(14),
      child: SizedBox(
        width: double.infinity,
        height: context.height(height ?? 132),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _AccidentMapPainter(),
              child: const SizedBox.expand(),
            ),
            Align(
              alignment: const Alignment(0.12, -0.08),
              child: Icon(
                Icons.location_on_rounded,
                size: context.width(28),
                color: AppSplashColors.cyanDeep,
                shadows: [
                  Shadow(
                    color: AppSplashColors.cyan.changeOpacity(0.45),
                    blurRadius: context.width(12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccidentMapPainter extends CustomPainter {
  static const _roadWidth = 10.0;
  static const _accentWidth = 2.2;
  static const _mapFill = Color(0xFFE7EEF3);
  static const _blockFill = Color(0xFFD5E1EA);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _mapFill);

    final block = Paint()..color = _blockFill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.12,
          size.width * 0.28,
          size.height * 0.32,
        ),
        const Radius.circular(6),
      ),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.18,
          size.width * 0.3,
          size.height * 0.28,
        ),
        const Radius.circular(6),
      ),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.58,
          size.width * 0.34,
          size.height * 0.28,
        ),
        const Radius.circular(6),
      ),
      block,
    );

    final road = Paint()
      ..color = const Color(0xFFF7FBFD)
      ..strokeWidth = _roadWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, 0),
      Offset(size.width * 0.46, size.height),
      road,
    );

    final accent = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.55)
      ..strokeWidth = _accentWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.52),
      Offset(size.width * 0.7, size.height * 0.52),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
