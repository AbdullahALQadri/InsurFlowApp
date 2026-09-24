import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';

/// One received push, rendered in the app's existing card language.
///
/// Shows only what the message actually carried: the FCM title and
/// body, when it arrived, and a "View claim" affordance when the
/// payload contained a claim id. Nothing is filled in when a field is
/// absent.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.isRead,
    this.onTap,
  });

  final AppNotification notification;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final radius = context.circularRadius(14);
    final title = notification.title?.trim();
    final body = notification.body?.trim();

    return Material(
      color: isRead ? colors.cardColor : colors.selectedBackgroundColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.borderColor),
          ),
          padding: context.spaceSymmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: context.spaceTop(4),
                child: Container(
                  width: context.width(8),
                  height: context.width(8),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.transparent : colors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              context.addHorizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Text(
                        title,
                        style: context.font16Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: isRead
                              ? FontWeightHelper.medium
                              : FontWeightHelper.semiBold,
                          height: 1.3,
                        ),
                      ),
                    if (body != null && body.isNotEmpty) ...[
                      context.addVerticalSpace(4),
                      Text(
                        body,
                        style: context.font14Regular?.copyWith(
                          color: colors.textSecondaryColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                    context.addVerticalSpace(8),
                    // Wraps instead of a Row: a long timestamp plus the
                    // "View claim" affordance overflows a narrow tile.
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: context.width(10),
                      runSpacing: context.height(4),
                      children: [
                        Text(
                          ClaimDateFormatter.lastUpdated(
                            notification.sentAt ?? notification.receivedAt,
                          ),
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                            fontSize: context.width(11),
                          ),
                        ),
                        if (notification.hasDestination)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: context.width(12),
                                color: colors.primaryColor,
                              ),
                              context.addHorizontalSpace(4),
                              Text(
                                strings.viewClaimFromNotification,
                                style: context.font14Bold?.copyWith(
                                  color: colors.primaryColor,
                                  fontWeight: FontWeightHelper.semiBold,
                                  fontSize: context.width(11),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
