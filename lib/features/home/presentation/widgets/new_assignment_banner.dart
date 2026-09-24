import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

class NewAssignmentBanner extends StatelessWidget {
  const NewAssignmentBanner({
    super.key,
    required this.claim,
    required this.onViewClaim,
  });

  final Claim claim;
  final VoidCallback onViewClaim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.primaryColor.changeOpacity(0.08),
        borderRadius: context.circularRadius(16),
        border: Border.all(color: colors.primaryColor.changeOpacity(0.3)),
      ),
      padding: context.spaceSymmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: context.spaceSymmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: colors.primaryColor,
                  borderRadius: context.circularRadius(12),
                ),
                child: Text(
                  strings.newAssignment.toUpperCase(),
                  style: context.font14Bold?.copyWith(
                    color: colors.onPrimaryColor,
                    fontWeight: FontWeightHelper.bold,
                  ),
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
          if (claim.incidentLocation != null &&
              claim.incidentLocation!.isNotEmpty) ...[
            context.addVerticalSpace(4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colors.textSecondaryColor,
                ),
                context.addHorizontalSpace(4),
                Expanded(
                  child: Text(
                    claim.incidentLocation!,
                    style: context.font14Regular?.copyWith(
                      color: colors.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          context.addVerticalSpace(12),
          AppPrimaryButton(
            label: strings.viewClaim,
            onPressed: onViewClaim,
            prominent: true,
          ),
        ],
      ),
    );
  }
}
