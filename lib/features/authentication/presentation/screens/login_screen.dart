import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/helpers/app_validators_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/authentication/presentation/widgets/login_hero.dart';
import 'package:insurflow/features/authentication/presentation/widgets/login_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _organizationController = TextEditingController();
  final _employeeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  String? _organizationError;
  String? _employeeError;
  String? _passwordError;
  String? _authError;

  @override
  void dispose() {
    _organizationController.dispose();
    _employeeController.dispose();
    _passwordController.dispose();
    _employeeFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_authError == null &&
        _organizationError == null &&
        _employeeError == null &&
        _passwordError == null) {
      return;
    }
    setState(() {
      _authError = null;
      _organizationError = null;
      _employeeError = null;
      _passwordError = null;
    });
  }

  void _onSignIn() {
    FocusScope.of(context).unfocus();
    final strings = AppStrings.of(context);

    final organizationError = AppValidators.requiredTrimmed(
      _organizationController.text,
      strings.requiredField,
    );
    final employeeError = AppValidators.requiredTrimmed(
      _employeeController.text,
      strings.requiredField,
    );
    final passwordError = AppValidators.validateLoginPassword(
      _passwordController.text,
      message: strings.passwordRequired,
    );

    setState(() {
      _authError = null;
      _organizationError = organizationError;
      _employeeError = employeeError;
      _passwordError = passwordError;
    });

    if (organizationError != null ||
        employeeError != null ||
        passwordError != null) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        organizationCode: _organizationController.text.trim(),
        employeeCode: _employeeController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.backgroundColor,
      systemNavigationBarIconBrightness: Theme.of(context).brightness ==
              Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.pushNamedAndRemoveUntil(
              Routes.mainScreen,
              predicate: (_) => false,
            );
          } else if (state is AuthUnauthenticated && state.failure != null) {
            setState(() {
              _authError = strings.loginMessageFor(state.failure!);
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadInProgress;
          return Scaffold(
            backgroundColor: colors.backgroundColor,
            resizeToAvoidBottomInset: true,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LoginHero(),
                        Padding(
                          padding: context.spaceSymmetric(
                            vertical: 28,
                            horizontal: 24,
                          ),
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  strings.welcomeBack,
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
                                context.addVerticalSpace(8),
                                Text(
                                  strings.loginSubtitle,
                                  style: context.font14Regular?.copyWith(
                                    color: colors.textSecondaryColor,
                                    height: 1.4,
                                  ),
                                ),
                                context.addVerticalSpace(28),
                                LoginTextField(
                                  label: strings.organizationCode,
                                  hint: strings.organizationCodeHint,
                                  controller: _organizationController,
                                  enabled: !isLoading,
                                  hasError:
                                      _organizationError != null ||
                                      _authError != null,
                                  errorText: _authError == null
                                      ? _organizationError
                                      : null,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.organizationName,
                                  ],
                                  onChanged: (_) => _clearErrors(),
                                  onSubmitted: (_) {
                                    _employeeFocus.requestFocus();
                                  },
                                ),
                                context.addVerticalSpace(16),
                                LoginTextField(
                                  label: strings.employeeCode,
                                  hint: strings.employeeCodeHint,
                                  controller: _employeeController,
                                  focusNode: _employeeFocus,
                                  enabled: !isLoading,
                                  hasError:
                                      _employeeError != null ||
                                      _authError != null,
                                  errorText: _authError == null
                                      ? _employeeError
                                      : null,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  onChanged: (_) => _clearErrors(),
                                  onSubmitted: (_) {
                                    _passwordFocus.requestFocus();
                                  },
                                ),
                                context.addVerticalSpace(16),
                                LoginTextField(
                                  label: strings.password,
                                  hint: strings.passwordHint,
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  enabled: !isLoading,
                                  obscureText: _obscurePassword,
                                  hasError:
                                      _passwordError != null ||
                                      _authError != null,
                                  errorText: _authError == null
                                      ? _passwordError
                                      : null,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onChanged: (_) => _clearErrors(),
                                  onSubmitted: (_) => _onSignIn(),
                                  suffix: IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                    tooltip: _obscurePassword
                                        ? strings.showPassword
                                        : strings.hidePassword,
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: context.width(22),
                                      color: colors.textSecondaryColor,
                                    ),
                                  ),
                                ),
                                if (_authError != null) ...[
                                  context.addVerticalSpace(10),
                                  Text(
                                    _authError!,
                                    style: context.font14Regular?.copyWith(
                                      color: colors.inputErrorBorderColor,
                                    ),
                                  ),
                                ],
                                context.addVerticalSpace(8),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    onPressed: isLoading ? null : () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: colors.primaryColor,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: context.spaceSymmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                    ),
                                    child: Text(
                                      strings.forgotPassword,
                                      style: context.font14Bold?.copyWith(
                                        color: colors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                context.addVerticalSpace(16),
                                AppPrimaryButton(
                                  label: strings.signIn,
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : _onSignIn,
                                ),
                                context.addVerticalSpace(32),
                                const _SecureFieldAccess(),
                                context.addVerticalSpace(8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SecureFieldAccess extends StatelessWidget {
  const _SecureFieldAccess();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: context.width(16),
          color: AppSplashColors.cyanDeep.changeOpacity(0.9),
        ),
        context.addHorizontalSpace(8),
        Text(
          AppStrings.of(context).secureFieldAccess,
          style: context.font14Regular?.copyWith(
            color: colors.textSecondaryColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
