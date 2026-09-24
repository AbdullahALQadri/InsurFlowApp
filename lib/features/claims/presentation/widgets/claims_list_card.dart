import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_status_badge.dart';

class ClaimsListCard extends StatelessWidget {
  const ClaimsListCard({super.key, required this.claim, required this.onTap});

  final ClaimPreview claim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final statusColor = ClaimStatusColors.of(claim.status);
    final isCorrection = claim.status == ClaimStatus.correctionRequired;
    final progress = claim.totalSteps == 0
        ? 0.0
        : claim.completedSteps / claim.totalSteps;

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.circularRadius(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(16),
            color: isCorrection ? statusColor.changeOpacity(0.04) : null,
            border: Border.all(
              color: isCorrection
                  ? statusColor.changeOpacity(0.35)
                  : colors.borderColor,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: context.width(4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(context.width(16)),
                      bottomStart: Radius.circular(context.width(16)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: context.spaceSymmetric(
                      vertical: 16,
                      horizontal: 14,
                    ),
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
                            ClaimStatusBadge(status: claim.status),
                          ],
                        ),
                        context.addVerticalSpace(8),
                        // The list endpoint returns `customerName` and
                        // `initialPlateNumber`; make/model/year arrive
                        // only with the claim detail call.
                        if (claim.customerName != null)
                          Text(
                            claim.customerName!,
                            style: context.font16Regular?.copyWith(
                              color: colors.textPrimaryColor,
                            ),
                          ),
                        if (claim.hasVehicleSpecification) ...[
                          context.addVerticalSpace(4),
                          Text(
                            claim.vehicle,
                            style: context.font14Regular?.copyWith(
                              color: colors.textPrimaryColor,
                            ),
                          ),
                        ],
                        if (claim.licensePlate.isNotEmpty) ...[
                          context.addVerticalSpace(4),
                          Text(
                            claim.licensePlate,
                            style: context.font14Regular?.copyWith(
                              color: colors.textSecondaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                        context.addVerticalSpace(10),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: context.width(16),
                              color: colors.textSecondaryColor,
                            ),
                            context.addHorizontalSpace(4),
                            Expanded(
                              child: Text(
                                claim.location,
                                style: context.font14Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        context.addVerticalSpace(6),
                        Text(
                          strings.lastUpdatedLabel,
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                          ),
                        ),
                        context.addVerticalSpace(2),
                        Text(
                          ClaimDateFormatter.lastUpdated(claim.lastUpdated),
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                          ),
                        ),
                        context.addVerticalSpace(12),
                        ClipRRect(
                          borderRadius: context.circularRadius(100),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: context.height(5),
                            backgroundColor: statusColor.changeOpacity(0.12),
                            color: statusColor,
                          ),
                        ),
                        context.addVerticalSpace(8),
                        Text(
                          strings.inspectionStepsCompleted(
                            claim.completedSteps,
                            claim.totalSteps,
                          ),
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                            fontSize: context.width(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
