import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

class ActiveInspectionCard extends StatelessWidget {
  const ActiveInspectionCard({
    super.key,
    required this.claim,
    required this.onContinue,
  });

  final Claim claim;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(16),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: context.spaceSymmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.successColor,
                  shape: BoxShape.circle,
                ),
              ),
              context.addHorizontalSpace(8),
              Text(
                strings.statusInProgress.toUpperCase(),
                style: context.font14Bold?.copyWith(
                  color: colors.successColor,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${strings.claimNumberPrefix}${claim.claimNumber ?? claim.id}',
                style: context.font14Bold?.copyWith(
                  color: colors.textPrimaryColor,
                ),
              ),
            ],
          ),
          context.addVerticalSpace(12),
          // `GET /claims` has no make/model — only the plate. Show
          // whichever the loaded claim actually carries, and nothing
          // when it carries neither.
          if (claim.vehicleMakeModel != null || claim.plateNumber != null)
            Text(
              claim.vehicleMakeModel ?? claim.plateNumber!,
              style: context.font16Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
          context.addVerticalSpace(12),
          AppPrimaryButton(
            label: strings.continueInspection,
            onPressed: onContinue,
            prominent: true,
          ),
        ],
      ),
    );
  }
}
