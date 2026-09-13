import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_progress.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_node.dart';

class VehicleLookupChecks extends StatelessWidget {
  const VehicleLookupChecks({super.key, required this.progress});

  final VehicleLookupProgress progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Column(
      children: [
        for (final item in VehicleLookupItem.values) ...[
          _LookupCheckRow(
            item: item,
            phase: progress.phaseOf(item),
            label: strings.vehicleLookupItemLabel(item),
          ),
          if (item != VehicleLookupItem.policy) context.addVerticalSpace(10),
        ],
      ],
    );
  }
}

class _LookupCheckRow extends StatelessWidget {
  const _LookupCheckRow({
    required this.item,
    required this.phase,
    required this.label,
  });

  final VehicleLookupItem item;
  final VehicleLookupItemPhase phase;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inspectionPhase = switch (phase) {
      VehicleLookupItemPhase.complete => InspectionStepPhase.completed,
      VehicleLookupItemPhase.checking => InspectionStepPhase.current,
      VehicleLookupItemPhase.pending => InspectionStepPhase.upcoming,
    };
    final emphasis = phase != VehicleLookupItemPhase.pending;

    return KeyedSubtree(
      key: Key('vehicle-lookup-check-${item.name}'),
      child: Row(
        children: [
          InspectionStepNode(
            phase: inspectionPhase,
            animationDelay: Duration.zero,
          ),
          context.addHorizontalSpace(10),
          Expanded(
            child: Text(
              label,
              style: context.font14Regular?.copyWith(
                color: emphasis
                    ? colors.textPrimaryColor
                    : colors.textSecondaryColor,
                fontWeight: emphasis
                    ? FontWeightHelper.medium
                    : FontWeightHelper.regular,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
