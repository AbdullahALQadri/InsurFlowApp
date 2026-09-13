import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_category_preview.dart';

class EvidencePhotoCard extends StatelessWidget {
  const EvidencePhotoCard({
    super.key,
    required this.slot,
    required this.onAddPhoto,
    this.wide = false,
  });

  final EvidenceSlot slot;
  final VoidCallback onAddPhoto;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final complete = slot.isComplete;
    final success = ClaimStatusColors.submitted;
    final border = complete ? success : colors.primaryColor.changeOpacity(0.55);

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('evidence-card-${slot.category.name}'),
        onTap: onAddPhoto,
        borderRadius: context.circularRadius(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(18),
            border: Border.all(color: border, width: complete ? 1.6 : 1.2),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Thumbnail(
                    slot: slot,
                    wide: wide,
                    success: success,
                    requiredLabel: strings.requiredEvidence,
                  ),
                ),
                context.addVerticalSpace(8),
                Row(
                  children: [
                    Icon(
                      _iconFor(slot.category),
                      size: context.width(16),
                      color: complete ? success : colors.primaryColor,
                    ),
                    context.addHorizontalSpace(6),
                    Expanded(
                      child: Text(
                        strings.evidenceCategoryLabel(slot.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.font14Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.semiBold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                context.addVerticalSpace(6),
                Row(
                  children: [
                    Icon(
                      complete
                          ? Icons.check_circle_rounded
                          : Icons.add_a_photo_outlined,
                      size: context.width(14),
                      color: complete ? success : colors.textSecondaryColor,
                    ),
                    context.addHorizontalSpace(4),
                    Expanded(
                      child: Text(
                        complete ? strings.photoAdded : strings.addPhoto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.font14Regular?.copyWith(
                          color: complete ? success : colors.textSecondaryColor,
                          fontWeight: complete
                              ? FontWeightHelper.semiBold
                              : FontWeightHelper.medium,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(EvidenceCategory category) {
    switch (category) {
      case EvidenceCategory.licensePlate:
        return Icons.pin_outlined;
      case EvidenceCategory.front:
        return Icons.directions_car_outlined;
      case EvidenceCategory.rear:
        return Icons.directions_car_filled_outlined;
      case EvidenceCategory.leftSide:
        return Icons.west_outlined;
      case EvidenceCategory.rightSide:
        return Icons.east_outlined;
      case EvidenceCategory.damageCloseUp:
        return Icons.zoom_in_outlined;
      case EvidenceCategory.accidentScene:
        return Icons.photo_camera_back_outlined;
    }
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.slot,
    required this.wide,
    required this.success,
    required this.requiredLabel,
  });

  final EvidenceSlot slot;
  final bool wide;
  final Color success;
  final String requiredLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final complete = slot.isComplete;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: complete
            ? success.changeOpacity(0.08)
            : colors.iconBackgroundColor,
        borderRadius: context.circularRadius(12),
      ),
      child: ClipRRect(
        borderRadius: context.circularRadius(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: context.spaceAroundAll(wide ? 6 : 4),
              child: EvidenceCategoryPreview(
                category: slot.category,
                accent: complete ? success : colors.primaryColor,
                muted: colors.borderColor,
                fill: colors.cardColor,
                plate: colors.backgroundColor,
                completed: complete,
              ),
            ),
            if (slot.isRequired && !complete)
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 6, horizontal: 6),
                  child: _RequiredBadge(label: requiredLabel),
                ),
              ),
            if (!complete)
              Align(
                alignment: Alignment.center,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.cardColor.changeOpacity(0.82),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: context.spaceSymmetric(vertical: 8, horizontal: 8),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: context.width(18),
                      color: colors.primaryColor,
                    ),
                  ),
                ),
              )
            else
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 6, horizontal: 6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: success,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: context.spaceSymmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: context.width(12),
                        color: colors.cardColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryColor.changeOpacity(0.12),
        borderRadius: context.circularRadius(100),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 3, horizontal: 7),
        child: Text(
          label,
          style: context.font14Bold?.copyWith(
            color: colors.primaryColor,
            fontWeight: FontWeightHelper.bold,
            height: 1.1,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
