import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/live_location_status_bar.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';
import 'package:insurflow/features/notifications/presentation/widgets/notification_bell.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.adjusterName,
    required this.subtitle,
    this.onAvatarTap,
    this.locationService,
  });

  final String greeting;
  final String adjusterName;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  /// Lets a test supply its own tracking service to the badge.
  final LocationTrackingService? locationService;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $adjusterName',
                style:
                    (context.isSmallScreen
                            ? context.font22Bold
                            : context.font26Bold)
                        ?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.bold,
                          height: 1.2,
                        ),
              ),
              context.addVerticalSpace(6),
              Text(
                subtitle,
                style: context.font14Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  height: 1.35,
                ),
              ),
              context.addVerticalSpace(8),
              LiveLocationStatusBar(service: locationService),
            ],
          ),
        ),
        context.addHorizontalSpace(8),
        const NotificationBell(),
        context.addHorizontalSpace(8),
        _ProfileAvatar(
          initial: adjusterName.trim().isEmpty
              ? '?'
              : adjusterName.trim().substring(0, 1),
          onTap: onAvatarTap,
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initial, this.onTap});

  final String initial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.width(44);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: context.buttonTheme.backgroundGradient,
            border: Border.all(
              color: colors.cardColor,
              width: context.width(2),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primaryColor.changeOpacity(0.22),
                blurRadius: context.width(10),
                offset: Offset(0, context.height(2)),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial.toUpperCase(),
              style: context.font16Bold?.copyWith(
                color: context.buttonTheme.foregroundColor,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
