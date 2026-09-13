import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';

/// Barely-visible road / workflow / data-flow lines behind the splash mark.
class SplashFlowLines extends StatelessWidget {
  const SplashFlowLines({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              return CustomPaint(
                size: Size(context.getWidth, context.getHeight),
                painter: _FlowLinesPainter(
                  t: progress.value,
                  lineWidth: context.width(_lineStroke),
                  accentWidth: context.width(_accentStroke),
                  nodeRadius: context.width(_nodeRadius),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

const _lineStroke = 1.15;
const _accentStroke = 1.35;
const _nodeRadius = 2.2;
const _lineOpacity = 0.055;
const _accentOpacity = 0.1;

class _FlowLinesPainter extends CustomPainter {
  _FlowLinesPainter({
    required this.t,
    required this.lineWidth,
    required this.accentWidth,
    required this.nodeRadius,
  });

  final double t;
  final double lineWidth;
  final double accentWidth;
  final double nodeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final road = _roadPath(size);
    final workflow = _workflowPath(size);
    final data = _dataPath(size);

    final basePaint = Paint()
      ..color = AppSplashColors.line.changeOpacity(_lineOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentPaint = Paint()
      ..color = AppSplashColors.glow.changeOpacity(_accentOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = accentWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(road, basePaint);
    canvas.drawPath(workflow, basePaint);
    canvas.drawPath(data, basePaint);

    _drawTravelingDash(canvas, road, accentPaint, t, dash: 36, gap: 88);
    _drawTravelingDash(canvas, workflow, accentPaint, 1 - t, dash: 22, gap: 70);
    _drawTravelingDash(canvas, data, accentPaint, t * 0.65, dash: 18, gap: 64);

    final nodePaint = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.12)
      ..style = PaintingStyle.fill;

    for (final offset in _nodes(size)) {
      canvas.drawCircle(offset, nodeRadius, nodePaint);
    }
  }

  Path _roadPath(Size size) {
    final path = Path()
      ..moveTo(size.width * -0.05, size.height * 0.78)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.62,
        size.width * 0.38,
        size.height * 0.88,
        size.width * 0.58,
        size.height * 0.7,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.52,
        size.width * 0.92,
        size.height * 0.64,
        size.width * 1.08,
        size.height * 0.46,
      );
    return path;
  }

  Path _workflowPath(Size size) {
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.22)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.18,
        size.width * 0.26,
        size.height * 0.42,
        size.width * 0.48,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.3,
        size.width * 0.7,
        size.height * 0.14,
        size.width * 0.94,
        size.height * 0.2,
      );
    return path;
  }

  Path _dataPath(Size size) {
    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.42)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.5,
        size.width * 0.34,
        size.height * 0.28,
        size.width * 0.52,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.7,
        size.width * 0.84,
        size.height * 0.34,
        size.width * 1.04,
        size.height * 0.58,
      );
    return path;
  }

  List<Offset> _nodes(Size size) {
    return [
      Offset(size.width * 0.48, size.height * 0.36),
      Offset(size.width * 0.58, size.height * 0.7),
      Offset(size.width * 0.52, size.height * 0.48),
    ];
  }

  void _drawTravelingDash(
    Canvas canvas,
    Path path,
    Paint paint,
    double t, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      if (length <= 0) continue;
      final period = dash + gap;
      var distance = (t * length) % period - dash;
      while (distance < length) {
        final start = distance.clamp(0, length).toDouble();
        final end = (distance + dash).clamp(0, length).toDouble();
        if (end > start) {
          canvas.drawPath(metric.extractPath(start, end), paint);
        }
        distance += period;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowLinesPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.accentWidth != accentWidth;
  }
}
