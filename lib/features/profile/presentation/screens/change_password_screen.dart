import 'package:flutter/material.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/authentication/domain/usecases/change_password_usecase.dart';
import 'package:insurflow/features/authentication/presentation/widgets/login_text_field.dart';

/// Changes the signed-in user's password through
/// `PUT /auth/change-password`.
///
/// Client-side validation mirrors exactly what the backend enforces —
/// both fields required and a minimum of 8 characters for the new
/// password — so the form never rejects something the server would
/// accept. A wrong current password is only knowable server-side and is
/// surfaced from its 401.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.onSubmit});

  /// Injected by tests in place of the real use case.
  final Future<bool> Function(String current, String next)? onSubmit;

  static Future<dynamic> open(BuildContext context) {
    return context.pushNamed(Routes.changePasswordScreen);
  }

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  var _isSaving = false;
  String? _serverError;
  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.textPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          strings.changePassword,
          style: context.font18Bold?.copyWith(
            color: colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
            padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
            children: [
              LoginTextField(
                key: const Key('current-password-field'),
                controller: _current,
                label: strings.currentPassword,
                hint: strings.currentPassword,
                obscureText: true,
                hasError: _currentError != null,
                errorText: _currentError,
              ),
              context.addVerticalSpace(16),
              LoginTextField(
                key: const Key('new-password-field'),
                controller: _next,
                label: strings.newPassword,
                hint: strings.newPassword,
                obscureText: true,
                hasError: _newError != null,
                errorText: _newError,
              ),
              context.addVerticalSpace(16),
              LoginTextField(
                key: const Key('confirm-password-field'),
                controller: _confirm,
                label: strings.confirmNewPassword,
                hint: strings.confirmNewPassword,
                obscureText: true,
                hasError: _confirmError != null,
                errorText: _confirmError,
              ),
              if (_serverError != null) ...[
                context.addVerticalSpace(14),
                Text(
                  _serverError!,
                  textAlign: TextAlign.center,
                  style: context.font14Regular?.copyWith(
                    color: colors.inputErrorBorderColor,
                    height: 1.4,
                  ),
                ),
              ],
              context.addVerticalSpace(24),
              AppPrimaryButton(
                key: const Key('change-password-submit'),
                label: strings.save,
                prominent: true,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
          ],
        ),
      ),
    );
  }

  /// Mirrors exactly what the backend enforces, so the form never
  /// blocks a password the server would accept.
  bool _validate() {
    final strings = AppStrings.of(context);
    final current = _current.text;
    final next = _next.text;

    final currentError = current.trim().isEmpty
        ? strings.currentPassword
        : null;
    String? newError;
    if (next.isEmpty) {
      newError = strings.newPassword;
    } else if (next.length < ChangePasswordUseCase.minPasswordLength) {
      newError = strings.passwordTooShort(
        ChangePasswordUseCase.minPasswordLength,
      );
    }
    final confirmError = _confirm.text != next
        ? strings.passwordsDoNotMatch
        : null;

    setState(() {
      _currentError = currentError;
      _newError = newError;
      _confirmError = confirmError;
    });

    return currentError == null && newError == null && confirmError == null;
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_validate()) return;

    final strings = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    bool succeeded;
    String? errorMessage;

    if (widget.onSubmit != null) {
      succeeded = await widget.onSubmit!(_current.text, _next.text);
      if (!succeeded) errorMessage = strings.currentPasswordIncorrect;
    } else {
      final result = await AppDependencies.instance.changePasswordUseCase(
        ChangePasswordParams(
          currentPassword: _current.text,
          newPassword: _next.text,
        ),
      );
      succeeded = result.isRight();
      result.leftMap((failure) {
        // The backend answers a wrong current password with 401, which
        // maps to UnauthorizedFailure — it does not mean the session
        // expired, so it gets its own message.
        errorMessage = failure is UnauthorizedFailure
            ? strings.currentPasswordIncorrect
            : strings.messageFor(failure);
      });
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (succeeded) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.passwordChanged)),
      );
      if (Navigator.of(context).canPop()) context.pop();
      return;
    }
    setState(() => _serverError = errorMessage);
  }
}
