import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';

/// Confirmation before signing out.
///
/// Nothing happens until the user explicitly confirms. Confirming
/// dispatches the real [AuthLogoutRequested], which runs the logout use
/// case and clears the access token *and* the stored session from
/// secure storage — the same path the rest of the app uses, not a
/// local-only reset.
class SignOutDialog {
  const SignOutDialog._();

  /// Returns true when the user confirmed and sign-out was dispatched.
  static Future<bool> confirmAndSignOut(BuildContext context) async {
    final confirmed = await show(context);
    if (!confirmed || !context.mounted) return false;

    context.read<AuthBloc>().add(const AuthLogoutRequested());
    return true;
  }

  /// Shows the dialog and reports the user's choice.
  static Future<bool> show(BuildContext context) async {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: context.circularRadius(18),
          ),
          title: Text(
            strings.signOutConfirmTitle,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
          content: Text(
            strings.signOutConfirmBody,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
              height: 1.45,
            ),
          ),
          actionsPadding: context.spaceSymmetric(
            vertical: 8,
            horizontal: 12,
          ),
          actions: [
            TextButton(
              key: const Key('sign-out-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                strings.cancel,
                style: context.font14Bold?.copyWith(
                  color: colors.textSecondaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
            ),
            TextButton(
              key: const Key('sign-out-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                strings.signOut,
                style: context.font14Bold?.copyWith(
                  color: colors.inputErrorBorderColor,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Dismissing by tapping outside must never sign the user out.
    return result ?? false;
  }
}
