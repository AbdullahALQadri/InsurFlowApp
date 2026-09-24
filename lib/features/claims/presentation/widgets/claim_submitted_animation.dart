import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';

/// A restrained success mark: a halo fades in, the ring draws itself,
/// then the checkmark strokes in and the whole badge settles.
///
/// Hand-painted rather than a Lottie file so it takes its colour from
/// [ClaimStatusColors.submitted] — the same tone the app already uses
/// for the SUBMITTED status — and stays crisp at any size. No new asset
/// is shipped for it.
///
/// Honours the platform "reduce motion" setting by rendering the final
/// frame immediately.
class ClaimSubmittedAnimation extends StatefulWidget {
  const ClaimSubmittedAnimation({
    super.key,
    required this.size,
    this.onCompleted,
  });

  final double size;
  final VoidCallback? onCompleted;

  static const Duration duration = Duration(milliseconds: 1250);

  @override
  State<ClaimSubmittedAnimation> createState() =>
      _ClaimSubmittedAnimationState();
}

class _ClaimSubmittedAnimationState extends State<ClaimSubmittedAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _halo;
  late final Animation<double> _ring;
  late final Animation<double> _check;
  late final Animation<double> _settle;

  var _notified = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ClaimSubmittedAnimation.duration,
    );

    _halo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _ring = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
    );
    _check = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    );
    // A single gentle overshoot, not a bounce.
    _settle = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.94), weight: 45),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.94,
          end: 1.04,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.04,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolved here because MediaQuery is not available in initState.
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      _notifyCompleted();
    } else {
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _notifyCompleted();
  }

  void _notifyCompleted() {
    if (_notified) return;
    _notified = true;
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const success = ClaimStatusColors.submitted;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.scale(
              scale: _settle.value,
              child: CustomPaint(
                painter: _SuccessMarkPainter(
                  color: success,
                  halo: _halo.value,
                  ring: _ring.value,
                  check: _check.value,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuccessMarkPainter extends CustomPainter {
  const _SuccessMarkPainter({
    required this.color,
    required this.halo,
    required this.ring,
    required this.check,
  });

  final Color color;

  /// 0 to 1 for each stage of the sequence.
  final double halo;
  final double ring;
  final double check;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.11;

    // Soft halo, deliberately faint so the mark stays the focus.
    if (halo > 0) {
      canvas.drawCircle(
        centre,
        radius * (0.82 + 0.18 * halo),
        Paint()..color = color.changeOpacity(0.10 * halo),
      );
      canvas.drawCircle(
        centre,
        radius * (0.62 + 0.10 * halo),
        Paint()..color = color.changeOpacity(0.14 * halo),
      );
    }

    // The ring draws clockwise from the top.
    if (ring > 0) {
      final ringRadius = radius - strokeWidth;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: ringRadius),
        -1.5707963,
        6.2831853 * ring,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    // Checkmark: a short down-stroke into a longer up-stroke, drawn as
    // one continuous path so it reads as a single gesture.
    if (check > 0) {
      final start = centre + Offset(-radius * 0.30, radius * 0.02);
      final elbow = centre + Offset(-radius * 0.08, radius * 0.26);
      final end = centre + Offset(radius * 0.32, -radius * 0.22);

      final firstLength = (elbow - start).distance;
      final secondLength = (end - elbow).distance;
      final total = firstLength + secondLength;
      final drawn = total * check;

      final path = Path()..moveTo(start.dx, start.dy);
      if (drawn <= firstLength) {
        final t = firstLength == 0 ? 1.0 : drawn / firstLength;
        final point = Offset.lerp(start, elbow, t)!;
        path.lineTo(point.dx, point.dy);
      } else {
        path.lineTo(elbow.dx, elbow.dy);
        final t = secondLength == 0
            ? 1.0
            : (drawn - firstLength) / secondLength;
        final point = Offset.lerp(elbow, end, t)!;
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_SuccessMarkPainter oldDelegate) {
    return oldDelegate.halo != halo ||
        oldDelegate.ring != ring ||
        oldDelegate.check != check ||
        oldDelegate.color != color;
  }
}
