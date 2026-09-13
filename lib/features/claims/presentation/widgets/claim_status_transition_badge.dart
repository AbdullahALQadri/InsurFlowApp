import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_status_badge.dart';

/// Plays a short ASSIGNED → IN PROGRESS handoff, then settles on the new badge.
class ClaimStatusTransitionBadge extends StatefulWidget {
  const ClaimStatusTransitionBadge({super.key, required this.status});

  final ClaimStatus status;

  @override
  State<ClaimStatusTransitionBadge> createState() =>
      _ClaimStatusTransitionBadgeState();
}

class _ClaimStatusTransitionBadgeState extends State<ClaimStatusTransitionBadge>
    with SingleTickerProviderStateMixin {
  static const _handoffDuration = Duration(milliseconds: 1800);

  ClaimStatus? _from;
  bool _showHandoff = false;
  Timer? _timer;
  late final AnimationController _pulse;
  late final Animation<double> _incomingScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _incomingScale = Tween<double>(
      begin: 0.86,
      end: 1,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(covariant ClaimStatusTransitionBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status == widget.status) return;

    _timer?.cancel();
    _from = oldWidget.status;
    _showHandoff = true;
    _pulse
      ..reset()
      ..forward();
    _timer = Timer(_handoffDuration, () {
      if (!mounted) return;
      setState(() => _showHandoff = false);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSize(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: AlignmentDirectional.centerEnd,
      child: _showHandoff && _from != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(opacity: 0.45, child: ClaimStatusBadge(status: _from!)),
                Padding(
                  padding: context.spaceHorizontal(6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: context.width(14),
                    color: colors.textSecondaryColor.changeOpacity(0.7),
                  ),
                ),
                ScaleTransition(
                  scale: _incomingScale,
                  child: ClaimStatusBadge(status: widget.status),
                ),
              ],
            )
          : ClaimStatusBadge(status: widget.status),
    );
  }
}
