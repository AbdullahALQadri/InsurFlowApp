import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';

class InspectionStepTrack extends StatelessWidget {
  const InspectionStepTrack({super.key, required this.step});

  /// 1-based current work step.
  final int step;

  static const _dot = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = InspectionProgress.totalCount;
    final current = step.clamp(1, total);

    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1)
            Expanded(
              child: SizedBox(
                height: context.height(2),
                child: ColoredBox(
                  color: i <= current
                      ? colors.primaryColor
                      : colors.borderColor,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < current
                  ? colors.primaryColor
                  : i == current
                  ? colors.primaryColor
                  : Colors.transparent,
              border: Border.all(
                color: i <= current ? colors.primaryColor : colors.borderColor,
                width: 1.5,
              ),
            ),
            child: SizedBox(
              width: context.width(_dot),
              height: context.width(_dot),
            ),
          ),
        ],
      ],
    );
  }
}
