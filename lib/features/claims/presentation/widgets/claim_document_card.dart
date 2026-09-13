import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/presentation/widgets/document_illustration.dart';

class ClaimDocumentCard extends StatelessWidget {
  const ClaimDocumentCard({
    super.key,
    required this.slot,
    required this.onUpload,
  });

  final ClaimDocumentSlot slot;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final uploaded = slot.isUploaded;
    final success = ClaimStatusColors.submitted;
    final accent = uploaded ? success : colors.primaryColor;
    final border = accent.changeOpacity(uploaded ? 0.7 : 0.45);

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('document-card-${slot.type.name}'),
        onTap: uploaded ? null : onUpload,
        borderRadius: context.circularRadius(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(18),
            border: Border.all(color: border, width: uploaded ? 1.6 : 1.2),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: context.width(72),
                  height: context.height(72),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: uploaded
                          ? success.changeOpacity(0.08)
                          : colors.iconBackgroundColor,
                      borderRadius: context.circularRadius(14),
                    ),
                    child: Padding(
                      padding: context.spaceSymmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
                      child: DocumentIllustration(
                        type: slot.type,
                        accent: accent,
                        muted: colors.borderColor,
                        fill: colors.cardColor,
                        surface: colors.backgroundColor,
                        completed: uploaded,
                      ),
                    ),
                  ),
                ),
                context.addHorizontalSpace(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.claimDocumentLabel(slot.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.font16Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.semiBold,
                          height: 1.2,
                        ),
                      ),
                      context.addVerticalSpace(6),
                      _RequirementBadge(
                        label: slot.isRequired
                            ? strings.requiredEvidence
                            : strings.optionalDocument,
                        isRequired: slot.isRequired,
                      ),
                    ],
                  ),
                ),
                context.addHorizontalSpace(8),
                _UploadAction(
                  type: slot.type,
                  uploaded: uploaded,
                  onUpload: onUpload,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementBadge extends StatelessWidget {
  const _RequirementBadge({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = isRequired ? colors.primaryColor : colors.textSecondaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.changeOpacity(0.1),
        borderRadius: context.circularRadius(100),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 3, horizontal: 8),
        child: Text(
          label,
          style: context.font14Bold?.copyWith(
            color: tone,
            fontWeight: FontWeightHelper.semiBold,
            height: 1.1,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _UploadAction extends StatelessWidget {
  const _UploadAction({
    required this.type,
    required this.uploaded,
    required this.onUpload,
  });

  final ClaimDocumentType type;
  final bool uploaded;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final success = ClaimStatusColors.submitted;

    if (uploaded) {
      return Text(
        strings.documentUploaded,
        style: context.font14Bold?.copyWith(
          color: success,
          fontWeight: FontWeightHelper.semiBold,
          height: 1.2,
        ),
      );
    }

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(10),
      child: InkWell(
        key: Key('document-upload-${type.name}'),
        onTap: onUpload,
        borderRadius: context.circularRadius(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(10),
            border: Border.all(color: colors.primaryColor.changeOpacity(0.7)),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 12),
            child: Text(
              strings.upload,
              style: context.font14Bold?.copyWith(
                color: colors.primaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
