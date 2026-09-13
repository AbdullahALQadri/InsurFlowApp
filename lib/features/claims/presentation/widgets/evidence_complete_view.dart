import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_complete_animation.dart';

class EvidenceCompleteView extends StatelessWidget {
  const EvidenceCompleteView({super.key, required this.evidence});

  final VehicleEvidence evidence;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;
    final lottieSize = context.isSmallScreen
        ? context.height(132)
        : context.height(148);

    return Column(
      children: [
        EvidenceCompleteAnimation(size: lottieSize),
        context.addVerticalSpace(8),
        Text(
          strings.requiredPhotosProgress(
            evidence.completedCount,
            evidence.totalCount,
          ),
          textAlign: TextAlign.center,
          style: context.font14Bold?.copyWith(
            color: colors.primaryColor,
            fontWeight: FontWeightHelper.medium,
            letterSpacing: 0.6,
          ),
        ),
        context.addVerticalSpace(10),
        Text(
          strings.evidenceCompleteHeadline,
          textAlign: TextAlign.center,
          style: context.font22Bold?.copyWith(
            color: colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
            height: 1.2,
          ),
        ),
        context.addVerticalSpace(8),
        Text(
          strings.allRequiredPhotosCaptured,
          textAlign: TextAlign.center,
          style: context.font16Regular?.copyWith(
            color: colors.textSecondaryColor,
            height: 1.4,
          ),
        ),
        context.addVerticalSpace(20),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: context.circularRadius(18),
            border: Border.all(color: success.changeOpacity(0.22)),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < evidence.slots.length; i++) ...[
                  _ChecklistRow(slot: evidence.slots[i]),
                  if (i < evidence.slots.length - 1)
                    Divider(
                      height: context.height(1),
                      color: colors.borderColor.changeOpacity(0.7),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.slot});

  final EvidenceSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;
    final markSize = context.width(22);

    return Padding(
      padding: context.spaceSymmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.evidenceCompleteItemLabel(slot.category),
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
    );
  }
}
