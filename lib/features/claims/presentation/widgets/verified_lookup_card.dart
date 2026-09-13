import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class VerifiedLookupCard extends StatelessWidget {
  const VerifiedLookupCard({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
    this.trailing,
    this.watermark,
    this.elevated = false,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final IconData? watermark;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(20),
        border: Border.all(color: colors.borderColor),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.textPrimaryColor.changeOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: context.circularRadius(20),
        child: Stack(
          children: [
            if (watermark != null)
              PositionedDirectional(
                end: -context.width(6),
                bottom: -context.height(10),
                child: Icon(
                  watermark,
                  size: context.width(92),
                  color: colors.primaryColor.changeOpacity(0.07),
                ),
              ),
            Padding(
              padding: context.spaceSymmetric(vertical: 18, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primaryColor.changeOpacity(0.1),
                          borderRadius: context.circularRadius(10),
                        ),
                        child: Padding(
                          padding: context.spaceAroundAll(8),
                          child: Icon(
                            icon,
                            size: context.width(18),
                            color: colors.primaryColor,
                          ),
                        ),
                      ),
                      context.addHorizontalSpace(10),
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: context.font14Bold?.copyWith(
                            color: colors.primaryColor,
                            letterSpacing: 1.2,
                            fontWeight: FontWeightHelper.semiBold,
                            fontSize: context.width(11),
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  context.addVerticalSpace(16),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
