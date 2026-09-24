import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/notifications/presentation/screens/notification_center_screen.dart';

/// Entry point to the notification list, with an unread badge.
///
/// The count comes from [NotificationCenterCubit], which only ever
/// holds pushes this device actually received — the badge is hidden
/// when nothing has arrived rather than showing a zero.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.width(44);

    return BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
      builder: (context, state) {
        final unread = state.unreadCount;

        return Semantics(
          label: AppStrings.of(context).notifications,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('notifications-bell'),
              onTap: () => NotificationCenterScreen.open(context),
              customBorder: const CircleBorder(),
              child: Ink(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.iconBackgroundColor,
                  border: Border.all(color: colors.borderColor),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: context.width(21),
                      color: colors.textPrimaryColor,
                    ),
                    if (unread > 0)
                      PositionedDirectional(
                        top: context.height(9),
                        end: context.width(9),
                        child: Container(
                          padding: context.spaceSymmetric(
                            vertical: 1,
                            horizontal: 4,
                          ),
                          constraints: BoxConstraints(
                            minWidth: context.width(15),
                          ),
                          decoration: BoxDecoration(
                            color: colors.inputErrorBorderColor,
                            borderRadius: context.circularRadius(100),
                            border: Border.all(color: colors.cardColor),
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            textAlign: TextAlign.center,
                            style: context.font14Bold?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeightHelper.bold,
                              fontSize: context.width(9),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
