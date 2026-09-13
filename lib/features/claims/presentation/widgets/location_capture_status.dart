import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class LocationCaptureStatus extends StatefulWidget {
  const LocationCaptureStatus({super.key});

  @override
  State<LocationCaptureStatus> createState() => _LocationCaptureStatusState();
}

class _LocationCaptureStatusState extends State<LocationCaptureStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 6, horizontal: 16),
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            return Column(
              children: [
                _StatusRow(
                  label: strings.gpsSignal,
                  value: strings.searchingEllipsis,
                  pulse: _t.value,
                ),
                Divider(
                  height: context.height(1),
                  thickness: context.height(1),
                  color: colors.borderColor,
                ),
                _StatusRow(
                  label: strings.locationAccuracy,
                  value: strings.calculatingEllipsis,
                  pulse: _t.value,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.pulse,
  });

  final String label;
  final String value;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dot = context.width(7);

    return Padding(
      padding: context.spaceVertical(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.font16Regular?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.medium,
                height: 1.3,
              ),
            ),
          ),
          Opacity(
            opacity: 0.55 + (pulse * 0.45),
            child: Text(
              value,
              style: context.font16Regular?.copyWith(
                color: colors.primaryColor,
                fontWeight: FontWeightHelper.medium,
                height: 1.3,
              ),
            ),
          ),
          context.addHorizontalSpace(8),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryColor.changeOpacity(0.35 + (pulse * 0.65)),
            ),
            child: SizedBox(width: dot, height: dot),
          ),
        ],
      ),
    );
  }
}
