import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';

class InspectionStepNode extends StatefulWidget {
  const InspectionStepNode({
    super.key,
    required this.phase,
    this.animationDelay = Duration.zero,
  });

  final InspectionStepPhase phase;
  final Duration animationDelay;

  @override
  State<InspectionStepNode> createState() => _InspectionStepNodeState();
}

class _InspectionStepNodeState extends State<InspectionStepNode>
    with TickerProviderStateMixin {
  static const _hairline = 1.5;

  late final AnimationController _check;
  late final AnimationController _pulse;
  late final Animation<double> _checkProgress;
  late final Animation<double> _pulseT;

  @override
  void initState() {
    super.initState();
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _checkProgress = CurvedAnimation(
      parent: _check,
      curve: Curves.easeOutCubic,
    );
    _pulseT = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);

    if (widget.phase == InspectionStepPhase.completed) {
      Future<void>.delayed(widget.animationDelay, () {
        if (mounted) _check.forward();
      });
    }
    if (widget.phase == InspectionStepPhase.current) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant InspectionStepNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase == widget.phase) return;

    if (widget.phase == InspectionStepPhase.completed) {
      _pulse.stop();
      _pulse.value = 0;
      _check.forward(from: 0);
    } else if (widget.phase == InspectionStepPhase.current) {
      _check.value = 0;
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _check.value = 0;
    }
  }

  @override
  void dispose() {
    _check.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCurrent = widget.phase == InspectionStepPhase.current;
    final size = context.width(isCurrent ? 24 : 22);

    return SizedBox(
      width: context.width(32),
      height: context.width(32),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_check, _pulse]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (isCurrent)
                  Transform.scale(
                    scale: 1 + (_pulseT.value * 0.28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primaryColor.changeOpacity(
                            0.18 + (_pulseT.value * 0.18),
                          ),
                          width: _hairline,
                        ),
                      ),
                      child: SizedBox(width: size, height: size),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: switch (widget.phase) {
                      InspectionStepPhase.completed => colors.primaryColor,
                      InspectionStepPhase.current => colors.primaryColor,
                      InspectionStepPhase.upcoming => Colors.transparent,
                    },
                    border: Border.all(
                      color: switch (widget.phase) {
                        InspectionStepPhase.completed => colors.primaryColor,
                        InspectionStepPhase.current => colors.primaryColor,
                        InspectionStepPhase.upcoming => colors.borderColor,
                      },
                      width: _hairline,
                    ),
                  ),
                  child: switch (widget.phase) {
                    InspectionStepPhase.completed => CustomPaint(
                      painter: _CheckPainter(
                        progress: _checkProgress.value,
                        color: colors.cardColor,
                      ),
                    ),
                    InspectionStepPhase.current => Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: context.width(8),
                          height: context.width(8),
                        ),
                      ),
                    ),
                    InspectionStepPhase.upcoming => const SizedBox.shrink(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final path = Path()
      ..moveTo(size.width * 0.26, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.34);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
