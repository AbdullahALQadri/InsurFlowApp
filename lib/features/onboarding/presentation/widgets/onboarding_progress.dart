import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

/// Segmented progress for the onboarding pager.
///
/// The active segment stretches into a pill while the others stay dots,
/// and the transition follows the pager's fractional offset so dragging
/// half a page shows half the movement.
///
/// Laid out with the pager's own direction, so under Arabic it fills
/// right-to-left along with the pages.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.count,
    required this.position,
  });

  final int count;

  /// Fractional page position, e.g. 1.5 while dragging between 1 and 2.
  final double position;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = context.height(6);
    final dot = context.width(6);
    final pill = context.width(26);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) context.addHorizontalSpace(6),
          // 1 on the active page, falling to 0 as it moves away.
          Builder(
            builder: (context) {
              final weight = (1 - (position - i).abs()).clamp(0.0, 1.0);
              return Container(
                width: dot + (pill - dot) * weight,
                height: height,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    colors.borderColor,
                    colors.primaryColor,
                    weight,
                  ),
                  borderRadius: BorderRadius.circular(height),
                  boxShadow: weight > 0.6
                      ? [
                          BoxShadow(
                            color: colors.primaryColor.changeOpacity(
                              0.28 * weight,
                            ),
                            blurRadius: context.width(8),
                            offset: Offset(0, context.height(2)),
                          ),
                        ]
                      : null,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
