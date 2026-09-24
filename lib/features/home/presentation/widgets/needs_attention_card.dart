import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_status_badge.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class NeedsAttentionCard extends StatelessWidget {
  const NeedsAttentionCard({
    super.key,
    required this.claim,
    required this.onFixClaim,
  });

  final ClaimPreview claim;
  final VoidCallback onFixClaim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = ClaimStatusColors.correctionRequired;
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs Attention',
          style: context.font18Bold?.copyWith(
            color: colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
        context.addVerticalSpace(12),
        Material(
          color: colors.cardColor,
          borderRadius: context.circularRadius(18),
          child: InkWell(
            onTap: onFixClaim,
            borderRadius: context.circularRadius(18),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: context.circularRadius(18),
                border: Border.all(color: accent.changeOpacity(0.28)),
                boxShadow: [
                  BoxShadow(
                    color: accent.changeOpacity(0.08),
                    blurRadius: context.width(16),
                    offset: Offset(0, context.height(4)),
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
                            claim.displayNumber,
                            style: context.font16Bold?.copyWith(
                              color: colors.textPrimaryColor,
                              fontWeight: FontWeightHelper.bold,
                            ),
                          ),
                        ),
                        const ClaimStatusBadge(
                          status: ClaimStatus.correctionRequired,
                        ),
                      ],
                    ),
                    context.addVerticalSpace(10),
                    Text(
                      claim.vehicle,
                      style: context.font16Regular?.copyWith(
                        color: colors.textPrimaryColor,
                      ),
                    ),
                    context.addVerticalSpace(4),
                    Text(
                      claim.licensePlate,
                      style: context.font14Regular?.copyWith(
                        color: colors.textSecondaryColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (claim.attentionNote != null) ...[
                      context.addVerticalSpace(12),
                      Text(
                        claim.attentionNote!,
                        style: context.font14Regular?.copyWith(
                          color: colors.textPrimaryColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                    context.addVerticalSpace(16),
                    AppPrimaryButton(
                      label: strings.fixCorrection,
                      onPressed: onFixClaim,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
