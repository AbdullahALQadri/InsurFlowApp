import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/notifications/domain/entities/app_notification.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/notifications/presentation/widgets/notification_tile.dart';

/// Lists the pushes this app instance has received.
///
/// Reads from [NotificationCenterCubit], which is fed only by real FCM
/// deliveries. The backend has no notification history endpoint, so the
/// list is empty on a fresh start and says so rather than showing
/// placeholder entries.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  static Future<dynamic> open(BuildContext context) {
    return context.pushNamed(Routes.notificationCenterScreen);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.backgroundColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.notifications,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
          actions: [
            BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
              builder: (context, state) {
                if (state.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  key: const Key('notifications-mark-all-read'),
                  onPressed: () =>
                      context.read<NotificationCenterCubit>().markAllRead(),
                  child: Text(
                    strings.markAllRead,
                    style: context.font14Bold?.copyWith(
                      color: colors.primaryColor,
                      fontWeight: FontWeightHelper.semiBold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
            builder: (context, state) {
              final banner = state.permissionGranted
                  ? null
                  : const _PermissionBanner(
                      key: Key('notifications-permission-banner'),
                    );

              if (state.notifications.isEmpty) {
                return Column(
                  children: [
                    if (banner != null)
                      Padding(
                        padding: context.spaceSymmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: banner,
                      ),
                    Expanded(child: _EmptyState(strings: strings)),
                  ],
                );
              }

              return ListView.separated(
                padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
                itemCount: state.notifications.length + (banner == null ? 1 : 2),
                separatorBuilder: (_, _) => context.addVerticalSpace(10),
                itemBuilder: (context, index) {
                  if (banner != null && index == 0) return banner;
                  final itemIndex = banner == null ? index : index - 1;

                  if (itemIndex == state.notifications.length) {
                    return Padding(
                      padding: context.spaceSymmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: Text(
                        strings.notificationsSessionNote,
                        textAlign: TextAlign.center,
                        style: context.font14Regular?.copyWith(
                          color: colors.textSecondaryColor,
                          fontSize: context.width(11),
                          height: 1.4,
                        ),
                      ),
                    );
                  }

                  final notification = state.notifications[itemIndex];
                  return NotificationTile(
                    key: ValueKey(notification.id),
                    notification: notification,
                    isRead: state.isRead(notification),
                    onTap: () => _open(context, notification),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, AppNotification notification) {
    context.read<NotificationCenterCubit>().markRead(notification);

    final claimId = notification.claimId;
    if (claimId == null) {
      // Nothing to navigate to: the payload carried no claim id. Say so
      // rather than opening an empty claim screen.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).notificationNoClaimLinked),
        ),
      );
      return;
    }
    ClaimDetailsScreen.open(context, claimId: claimId);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: context.spaceHorizontal(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: context.width(48),
              color: colors.textSecondaryColor,
            ),
            context.addVerticalSpace(14),
            Text(
              strings.notificationsEmptyTitle,
              style: context.font18Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
            context.addVerticalSpace(6),
            Text(
              strings.notificationsEmptyBody,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the OS has denied notification permission. Offers the
/// prompt again rather than silently receiving nothing.
class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.selectedBackgroundColor,
        borderRadius: context.circularRadius(14),
        border: Border.all(color: colors.borderColor),
      ),
      padding: context.spaceSymmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: context.width(20),
            color: colors.textSecondaryColor,
          ),
          context.addHorizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.notificationsDisabledTitle,
                  style: context.font16Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
                context.addVerticalSpace(4),
                Text(
                  strings.notificationsDisabledBody,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          context.addHorizontalSpace(8),
          TextButton(
            key: const Key('notifications-enable'),
            onPressed: () =>
                context.read<NotificationCenterCubit>().requestPermission(),
            child: Text(
              strings.enableNotifications,
              style: context.font14Bold?.copyWith(
                color: colors.primaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
