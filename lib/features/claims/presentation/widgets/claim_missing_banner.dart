import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';

/// Names the sections the backend would still reject the claim for.
///
/// `POST /claims/{id}/inspection/submit` answers `Inspection
/// incomplete. Missing: vehicle, accident, location, evidence,
/// signature`, and [ClaimReviewSummary.missingSections] mirrors that
/// check exactly — so this says the same thing before the request is
/// spent, instead of leaving a disabled button unexplained.
class ClaimMissingBanner extends StatelessWidget {
  const ClaimMissingBanner({super.key, required this.sections});

  final List<ClaimReviewSectionId> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final strings = AppStrings.of(context);
    final warning = colors.warningColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: warning.changeOpacity(0.1),
        borderRadius: context.circularRadius(16),
        border: Border.all(color: warning.changeOpacity(0.28)),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 14, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: warning,
              size: context.width(20),
            ),
            context.addHorizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.claimNotReadyTitle,
                    style: context.font16Bold?.copyWith(
                      color: colors.textPrimaryColor,
                      fontWeight: FontWeightHelper.semiBold,
                      height: 1.3,
                    ),
                  ),
                  context.addVerticalSpace(4),
                  Text(
                    strings.claimStillNeeds(
                      sections.map(strings.reviewSectionLabel).toList(),
                    ),
                    style: context.font14Regular?.copyWith(
                      color: colors.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
