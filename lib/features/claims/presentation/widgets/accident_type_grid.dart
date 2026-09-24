import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';

class AccidentTypeGrid extends StatelessWidget {
  const AccidentTypeGrid({
    super.key,
    required this.selected,
    required this.onSelected,
    this.hasError = false,
    this.attention = false,
    this.errorText,
    this.helperText,
  });

  final AccidentType? selected;
  final ValueChanged<AccidentType> onSelected;
  final bool hasError;
  final bool attention;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              strings.accidentType,
              style: context.font14Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
            Text(
              ' *',
              style: context.font14Bold?.copyWith(
                color: attention
                    ? colors.warningColor
                    : colors.primaryColor,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ],
        ),
        context.addVerticalSpace(10),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = context.width(10);
            final tileWidth = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: context.height(10),
              children: [
                for (final type in AccidentType.values)
                  SizedBox(
                    width: type == AccidentType.other
                        ? constraints.maxWidth
                        : tileWidth,
                    child: _TypeTile(
                      type: type,
                      label: strings.accidentTypeLabel(type),
                      selected: selected == type,
                      onTap: () => onSelected(type),
                      invalid: hasError && selected == null,
                      attention: attention && selected == null,
                    ),
                  ),
              ],
            );
          },
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          context.addVerticalSpace(8),
          Text(
            errorText!,
            style: context.font14Regular?.copyWith(
              color: colors.inputErrorBorderColor,
            ),
          ),
        ] else if (helperText != null && helperText!.isNotEmpty) ...[
          context.addVerticalSpace(8),
          Text(
            helperText!,
            style: context.font14Regular?.copyWith(
              color: context.colors.warningColor,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.invalid,
    required this.attention,
  });

  final AccidentType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool invalid;
  final bool attention;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final warning = colors.warningColor;
    final border = invalid
        ? colors.inputErrorBorderColor
        : attention
        ? warning
        : selected
        ? colors.primaryColor
        : colors.borderColor;

    return Material(
      color: selected
          ? colors.primaryColor.changeOpacity(0.08)
          : attention
          ? warning.changeOpacity(0.06)
          : colors.cardColor,
      borderRadius: context.circularRadius(16),
      child: InkWell(
        key: Key('accident-type-${type.name}'),
        onTap: onTap,
        borderRadius: context.circularRadius(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(16),
            border: Border.all(color: border, width: selected ? 1.6 : 1),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Icon(
                  _iconFor(type),
                  size: context.width(28),
                  color: selected
                      ? colors.primaryColor
                      : colors.textSecondaryColor,
                ),
                context.addVerticalSpace(8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.font14Bold?.copyWith(
                    color: selected
                        ? colors.textPrimaryColor
                        : colors.textSecondaryColor,
                    fontWeight: selected
                        ? FontWeightHelper.semiBold
                        : FontWeightHelper.medium,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AccidentType type) {
    switch (type) {
      case AccidentType.collision:
        return Icons.directions_car_outlined;
      case AccidentType.rearEndCollision:
        return Icons.car_crash_outlined;
      case AccidentType.sideImpact:
        return Icons.sync_alt_rounded;
      case AccidentType.parkingDamage:
        return Icons.local_parking_outlined;
      case AccidentType.other:
        return Icons.more_horiz_rounded;
    }
  }
}
