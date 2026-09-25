import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';

class LocationStatusBar extends StatelessWidget {
  const LocationStatusBar({
    super.key,
    required this.status,
    this.lastUpdated,
  });

  final GpsStatus status;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    Color badgeColor;
    switch (status) {
      case GpsStatus.active:
        badgeColor = colors.successColor;
        break;
      case GpsStatus.weakGps:
        badgeColor = colors.warningColor;
        break;
      case GpsStatus.disabled:
      case GpsStatus.permissionDenied:
        badgeColor = colors.dangerColor;
        break;
      case GpsStatus.waitingConnection:
        badgeColor = colors.textSecondaryColor;
        break;
    }

    return Container(
      padding: context.spaceSymmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: context.circularRadius(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          context.addHorizontalSpace(6),
          Text(
            strings.gpsStatusLabel(status),
            style: context.font14Regular?.copyWith(
              color: colors.textPrimaryColor,
              fontSize: context.width(11),
            ),
          ),
        ],
      ),
    );
  }
}
