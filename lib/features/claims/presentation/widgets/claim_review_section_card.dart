import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class ClaimReviewSectionCard extends StatelessWidget {
  const ClaimReviewSectionCard({
    super.key,
    required this.title,
    required this.checks,
    required this.onEdit,
    this.editKey,
    this.media,
  });

  final String title;
  final List<String> checks;
  final VoidCallback onEdit;
  final Key? editKey;

  /// Optional preview shown under the checks — evidence thumbnails or
  /// the captured signature.
  final Widget? media;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(20),
        border: Border.all(color: colors.borderColor.changeOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimaryColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: Offset(0, context.height(6)),
          ),
        ],
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: context.font14Bold?.copyWith(
                      color: colors.textSecondaryColor,
                      fontWeight: FontWeightHelper.semiBold,
                      letterSpacing: 1.2,
                      height: 1.2,
                    ),
                  ),
                ),
                TextButton(
                  key: editKey,
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primaryColor,
                    padding: context.spaceSymmetric(vertical: 4, horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    strings.edit,
                    style: context.font14Bold?.copyWith(
                      color: colors.primaryColor,
                      fontWeight: FontWeightHelper.semiBold,
                    ),
                  ),
                ),
              ],
            ),
            context.addVerticalSpace(10),
            for (var i = 0; i < checks.length; i++) ...[
              _CheckRow(label: checks[i], success: success),
              if (i < checks.length - 1) context.addVerticalSpace(8),
            ],
            if (media != null) ...[
              context.addVerticalSpace(12),
              media!,
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.success});

  final String label;
  final Color success;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final markSize = context.width(20);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        context.addHorizontalSpace(10),
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
      ],
    );
  }
}
