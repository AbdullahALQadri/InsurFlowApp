import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_validation_progress.dart';

class ClaimValidationChecks extends StatelessWidget {
  const ClaimValidationChecks({super.key, required this.progress});

  final ClaimValidationProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = ClaimStatusColors.submitted;
    final visible = progress.visibleItems;

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: visible.isEmpty
          ? const SizedBox(width: double.infinity)
          : DecoratedBox(
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: context.circularRadius(18),
                border: Border.all(color: success.changeOpacity(0.22)),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimaryColor.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: Offset(0, context.height(4)),
                  ),
                ],
              ),
              child: Padding(
                padding: context.spaceSymmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      _ValidationCheckRow(item: visible[i]),
                      if (i < visible.length - 1)
                        Divider(
                          height: context.height(1),
                          color: colors.borderColor.changeOpacity(0.7),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _ValidationCheckRow extends StatelessWidget {
  const _ValidationCheckRow({required this.item});

  final ClaimValidationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;
    final markSize = context.width(22);

    return KeyedSubtree(
      key: Key('claim-validation-check-${item.name}'),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 8, horizontal: 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                strings.claimValidationItemLabel(item),
                style: context.font16Regular?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.medium,
                  height: 1.25,
                ),
              ),
            ),
            context.addHorizontalSpace(12),
            SizedBox(
              width: markSize,
              height: markSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: success.changeOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: context.width(14),
                  color: success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
