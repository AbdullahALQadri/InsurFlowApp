import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';
import 'package:insurflow/features/profile/presentation/screens/change_password_screen.dart';
import 'package:insurflow/features/profile/presentation/widgets/accent_picker_sheet.dart';
import 'package:insurflow/features/profile/presentation/widgets/profile_section.dart';
import 'package:insurflow/features/profile/presentation/widgets/sign_out_dialog.dart';

/// The signed-in adjuster's profile.
///
/// Every personal value comes from the `user` object in the
/// `POST /auth/login` response — `id`, `name`, `employeeCode`, `role`,
/// `organizationId`, `organizationName` — which is the only user data
/// any mobile-reachable endpoint returns. There is no profile endpoint
/// and **no email or phone number anywhere in the mobile API**, so
/// neither is shown; a row appears only when the backend actually sent
/// its value.
///
/// Language and theme are device preferences, not backend data, and are
/// persisted locally.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final authState = context.watch<AuthBloc>().state;
    final session = authState is AuthAuthenticated ? authState.session : null;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: context.spaceSymmetric(vertical: 20, horizontal: 20),
          children: [
            _ProfileHeader(session: session),
            context.addVerticalSpace(24),
            _profileInformation(context, strings, session),
            _accountInformation(context, strings, session),
            _preferences(context, strings),
            _security(context, strings),
            context.addVerticalSpace(8),
            const _SignOutButton(),
            context.addVerticalSpace(12),
          ],
        ),
      ),
    );
  }

  // --- login response: user.name / employeeCode / role -------------------

  Widget _profileInformation(
    BuildContext context,
    AppStrings strings,
    AuthSession? session,
  ) {
    final rows = <ProfileRow?>[
      ProfileRow.ifPresent(
        icon: Icons.badge_outlined,
        label: strings.fullNameLabel,
        value: session?.displayName,
      ),
      ProfileRow.ifPresent(
        icon: Icons.pin_outlined,
        label: strings.employeeCodeLabel,
        value: session?.employeeCode,
      ),
      ProfileRow.ifPresent(
        icon: Icons.work_outline_rounded,
        label: strings.roleLabel,
        // A known backend role gets a translation; anything new is
        // shown as the backend spelled it.
        value: strings.userRoleLabel(session?.role),
      ),
    ].whereType<ProfileRow>().toList();

    if (rows.isEmpty) return const SizedBox.shrink();
    return _sectionWrapper(
      context,
      ProfileSection(
        label: strings.profileInformation,
        children: _withLastFlag(rows),
      ),
    );
  }

  // --- login response: organizationName / organizationId / user.id -------

  Widget _accountInformation(
    BuildContext context,
    AppStrings strings,
    AuthSession? session,
  ) {
    final rows = <ProfileRow?>[
      ProfileRow.ifPresent(
        icon: Icons.apartment_rounded,
        label: strings.organizationLabel,
        value: session?.organizationName,
      ),
      ProfileRow.ifPresent(
        icon: Icons.qr_code_2_rounded,
        label: strings.organizationCodeLabel,
        value: session?.organizationCode,
      ),
      ProfileRow.ifPresent(
        icon: Icons.fingerprint_rounded,
        label: strings.userIdLabel,
        value: session?.userId,
      ),
    ].whereType<ProfileRow>().toList();

    if (rows.isEmpty) return const SizedBox.shrink();
    return _sectionWrapper(
      context,
      ProfileSection(
        label: strings.accountInformation,
        children: _withLastFlag(rows),
      ),
    );
  }

  // --- device preferences -------------------------------------------------

  Widget _preferences(BuildContext context, AppStrings strings) {
    return _sectionWrapper(
      context,
      ProfileSection(
        label: strings.preferencesSection,
        children: [
          BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
            builder: (context, state) {
              return ProfileRow(
                key: const Key('profile-notifications'),
                icon: Icons.notifications_none_rounded,
                label: strings.notificationSettings,
                value: state.permissionGranted
                    ? strings.notificationsOn
                    : strings.notificationsOff,
                onTap: () => NotificationCenterScreen.open(context),
              );
            },
          ),
          const _LanguageRow(),
          const _ThemeRow(),
          const _AccentRow(isLast: true),
        ],
      ),
    );
  }

  // --- PUT /auth/change-password -----------------------------------------

  Widget _security(BuildContext context, AppStrings strings) {
    return _sectionWrapper(
      context,
      ProfileSection(
        label: strings.securitySection,
        children: [
          ProfileRow(
            key: const Key('profile-change-password'),
            icon: Icons.lock_outline_rounded,
            label: strings.changePassword,
            value: null,
            isLast: true,
            onTap: () => ChangePasswordScreen.open(context),
          ),
        ],
      ),
    );
  }

  Widget _sectionWrapper(BuildContext context, Widget child) {
    return Padding(padding: context.spaceBottom(20), child: child);
  }

  /// Drops the divider under the final row of a section.
  List<Widget> _withLastFlag(List<ProfileRow> rows) {
    return [
      for (var i = 0; i < rows.length; i++)
        ProfileRow(
          key: rows[i].key,
          icon: rows[i].icon,
          label: rows[i].label,
          value: rows[i].value,
          trailing: rows[i].trailing,
          onTap: rows[i].onTap,
          isLast: i == rows.length - 1,
        ),
    ];
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.session});

  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final name = session?.displayNameOrCode;
    final role = strings.userRoleLabel(session?.role);
    final initial = session?.initial;

    return Column(
      children: [
        Container(
          width: context.width(88),
          height: context.width(88),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: context.buttonTheme.backgroundGradient,
            boxShadow: [
              BoxShadow(
                color: colors.primaryColor.changeOpacity(0.28),
                blurRadius: context.width(20),
                offset: Offset(0, context.height(6)),
              ),
            ],
          ),
          child: Center(
            child: initial == null
                // No name from the backend, so no initial is invented.
                ? Icon(
                    Icons.person_outline_rounded,
                    size: context.width(38),
                    color: context.buttonTheme.foregroundColor,
                  )
                : Text(
                    initial,
                    style: context.font26Bold?.copyWith(
                      color: context.buttonTheme.foregroundColor,
                      fontWeight: FontWeightHelper.bold,
                    ),
                  ),
          ),
        ),
        context.addVerticalSpace(14),
        if (name != null)
          Text(
            name,
            textAlign: TextAlign.center,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              height: 1.25,
            ),
          ),
        if (role != null) ...[
          context.addVerticalSpace(6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.iconBackgroundColor,
              borderRadius: context.circularRadius(100),
              border: Border.all(color: colors.borderColor),
            ),
            child: Padding(
              padding: context.spaceSymmetric(vertical: 5, horizontal: 12),
              child: Text(
                role,
                style: context.font14Bold?.copyWith(
                  color: colors.primaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  fontSize: context.width(12),
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
        if (name == null && role == null)
          Text(
            strings.profileFieldUnavailable,
            textAlign: TextAlign.center,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
            ),
          ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocBuilder<AppPreferencesCubit, AppPreferences>(
      builder: (context, preferences) {
        return ProfileRow(
          key: const Key('profile-language'),
          icon: Icons.translate_rounded,
          label: strings.languageLabel,
          value: switch (preferences.localeCode) {
            'en' => strings.languageEnglish,
            'ar' => strings.languageArabic,
            _ => strings.languageSystem,
          },
          onTap: () => _pick(context, preferences),
        );
      },
    );
  }

  Future<void> _pick(BuildContext context, AppPreferences preferences) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<AppPreferencesCubit>();

    final choice = await _showOptionSheet<String?>(
      context,
      title: strings.languageLabel,
      options: [
        _Option(value: null, label: strings.languageSystem),
        _Option(value: 'en', label: strings.languageEnglish),
        _Option(value: 'ar', label: strings.languageArabic),
      ],
      selected: preferences.localeCode,
    );
    if (!choice.isSentinel) return;
    await cubit.setLocale(choice.value);
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocBuilder<AppPreferencesCubit, AppPreferences>(
      builder: (context, preferences) {
        return ProfileRow(
          key: const Key('profile-theme'),
          icon: switch (preferences.themeMode) {
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
            ThemeMode.system => Icons.brightness_auto_outlined,
          },
          label: strings.themeLabel,
          value: switch (preferences.themeMode) {
            ThemeMode.light => strings.themeLight,
            ThemeMode.dark => strings.themeDark,
            ThemeMode.system => strings.themeSystem,
          },
          onTap: () => _pick(context, preferences),
        );
      },
    );
  }

  Future<void> _pick(BuildContext context, AppPreferences preferences) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<AppPreferencesCubit>();

    final choice = await _showOptionSheet<ThemeMode>(
      context,
      title: strings.themeLabel,
      options: [
        _Option(value: ThemeMode.system, label: strings.themeSystem),
        _Option(value: ThemeMode.light, label: strings.themeLight),
        _Option(value: ThemeMode.dark, label: strings.themeDark),
      ],
      selected: preferences.themeMode,
    );
    if (!choice.isSentinel) return;
    await cubit.setThemeMode(choice.value!);
  }
}

class _AccentRow extends StatelessWidget {
  const _AccentRow({this.isLast = false});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = context.colors;

    return BlocBuilder<AppPreferencesCubit, AppPreferences>(
      builder: (context, preferences) {
        return ProfileRow(
          key: const Key('profile-accent'),
          icon: Icons.palette_outlined,
          label: strings.accentLabel,
          isLast: isLast,
          value: preferences.usesCustomAccent
              ? strings.accentCustom
              : strings.accentDefault,
          trailing: Container(
            width: context.width(22),
            height: context.width(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Shows the accent actually in effect, which for a custom
              // pick is the contrast-adjusted colour, not the raw one.
              color: colors.primaryColor,
              border: Border.all(color: colors.borderColor),
            ),
          ),
          onTap: () => AccentPickerSheet.show(context),
        );
      },
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(16),
      child: InkWell(
        key: const Key('profile-sign-out'),
        borderRadius: context.circularRadius(16),
        onTap: () => SignOutDialog.confirmAndSignOut(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(16),
            border: Border.all(
              color: colors.inputErrorBorderColor.changeOpacity(0.5),
            ),
          ),
          padding: context.spaceSymmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: context.width(18),
                color: colors.inputErrorBorderColor,
              ),
              context.addHorizontalSpace(10),
              Text(
                strings.signOut,
                style: context.font16Bold?.copyWith(
                  color: colors.inputErrorBorderColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- option sheet ----------------------------------------------------------

class _Option<T> {
  const _Option({required this.value, required this.label});

  final T value;
  final String label;
}

/// Distinguishes "dismissed" from "chose the null option" (System
/// language), which a plain nullable return cannot express.
class _Choice<T> {
  const _Choice.picked(this.value) : isSentinel = true;
  const _Choice.dismissed() : value = null, isSentinel = false;

  final T? value;
  final bool isSentinel;
}

Future<_Choice<T>> _showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<_Option<T>> options,
  required T? selected,
}) async {
  final colors = context.colors;

  final result = await showModalBottomSheet<_Choice<T>>(
    context: context,
    backgroundColor: colors.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.width(20)),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
              child: Text(
                title,
                style: context.font18Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
            ),
            for (final option in options)
              ListTile(
                key: ValueKey('option-${option.value}'),
                title: Text(
                  option.label,
                  style: context.font16Regular?.copyWith(
                    color: colors.textPrimaryColor,
                  ),
                ),
                trailing: option.value == selected
                    ? Icon(Icons.check_rounded, color: colors.primaryColor)
                    : null,
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_Choice<T>.picked(option.value)),
              ),
            context.addVerticalSpace(8),
          ],
        ),
      );
    },
  );

  return result ?? _Choice<T>.dismissed();
}
