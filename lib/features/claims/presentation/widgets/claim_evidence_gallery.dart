import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';

/// Renders `evidence[]` from `GET /claims/{id}`.
///
/// Each item carries `imageType`, a Cloudinary `url`, `uploadedBy` and
/// `uploadedAt`. Images load straight from the returned URL — nothing
/// is cached locally or substituted when a URL fails to load.
class ClaimEvidenceGallery extends StatelessWidget {
  const ClaimEvidenceGallery({super.key, required this.items, this.onOpen});

  final List<ClaimEvidenceItem> items;
  final ValueChanged<ClaimEvidenceItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.width(10),
        mainAxisSpacing: context.width(10),
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _EvidenceTile(
          item: item,
          onTap: onOpen == null ? null : () => onOpen!(item),
        );
      },
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.item, this.onTap});

  final ClaimEvidenceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final radius = context.circularRadius(12);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: radius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  border: Border.all(color: colors.borderColor),
                  borderRadius: radius,
                ),
                child: SizedBox.expand(
                  child: ClaimRemoteImage(
                    url: item.url,
                    unavailableLabel: strings.evidenceImageUnavailable,
                  ),
                ),
              ),
            ),
          ),
          context.addVerticalSpace(6),
          // `imageType` is a backend enum (VEHICLE_FRONT, DAMAGE_CLOSEUP,
          // ...). Shown as sent, only re-cased for readability.
          if (item.imageTypeLabel != null)
            Text(
              item.imageTypeLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.font14Regular?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
                fontSize: context.width(12),
              ),
            ),
          if (item.uploadedAt != null)
            Text(
              ClaimDateFormatter.capturedAt(item.uploadedAt!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
                fontSize: context.width(11),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loads an image from a backend-provided URL.
///
/// Shows a progress indicator while loading and a plain "unavailable"
/// state on failure — never a stand-in image.
class ClaimRemoteImage extends StatelessWidget {
  const ClaimRemoteImage({
    super.key,
    required this.url,
    required this.unavailableLabel,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final String unavailableLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final source = url?.trim();
    if (source == null || source.isEmpty) {
      return _Unavailable(label: unavailableLabel);
    }

    return Image.network(
      source,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: context.width(20),
            height: context.width(20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primaryColor,
              value: progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => _Unavailable(label: unavailableLabel),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: context.spaceAroundAll(8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.font14Regular?.copyWith(
            color: colors.textSecondaryColor,
            fontSize: context.width(11),
          ),
        ),
      ),
    );
  }
}
