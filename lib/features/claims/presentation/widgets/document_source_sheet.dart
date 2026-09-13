import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';

class DocumentSourceSheet extends StatelessWidget {
  const DocumentSourceSheet({super.key, required this.type});

  final ClaimDocumentType type;

  static Future<DocumentSource?> show(
    BuildContext context, {
    required ClaimDocumentType type,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<DocumentSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: colors.textPrimaryColor.changeOpacity(0.28),
      builder: (_) => DocumentSourceSheet(type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colors.cardColor,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.borderColor,
                      borderRadius: context.circularRadius(100),
                    ),
                    child: SizedBox(
                      width: context.width(36),
                      height: context.height(4),
                    ),
                  ),
                ),
                context.addVerticalSpace(16),
                Text(
                  strings.claimDocumentLabel(type),
                  textAlign: TextAlign.center,
                  style: context.font18Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
                context.addVerticalSpace(4),
                Text(
                  strings.uploadDocumentSource,
                  textAlign: TextAlign.center,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                  ),
                ),
                context.addVerticalSpace(12),
                for (final source in DocumentSource.values)
                  _SourceRow(
                    source: source,
                    label: strings.documentSourceLabel(source),
                    onTap: () => Navigator.of(context).pop(source),
                  ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.source,
    required this.label,
    required this.onTap,
  });

  final DocumentSource source;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: context.spaceBottom(8),
      child: Material(
        color: colors.iconBackgroundColor,
        borderRadius: context.circularRadius(14),
        child: InkWell(
          key: Key('document-source-${source.name}'),
          onTap: onTap,
          borderRadius: context.circularRadius(14),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 14, horizontal: 14),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryColor.changeOpacity(0.1),
                    borderRadius: context.circularRadius(10),
                  ),
                  child: Padding(
                    padding: context.spaceSymmetric(vertical: 8, horizontal: 8),
                    child: Icon(
                      _iconFor(source),
                      size: context.width(20),
                      color: colors.primaryColor,
                    ),
                  ),
                ),
                context.addHorizontalSpace(12),
                Expanded(
                  child: Text(
                    label,
                    style: context.font16Bold?.copyWith(
                      color: colors.textPrimaryColor,
                      fontWeight: FontWeightHelper.semiBold,
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

  IconData _iconFor(DocumentSource source) {
    switch (source) {
      case DocumentSource.camera:
        return Icons.photo_camera_outlined;
      case DocumentSource.gallery:
        return Icons.photo_library_outlined;
      case DocumentSource.files:
        return Icons.folder_open_outlined;
    }
  }
}
