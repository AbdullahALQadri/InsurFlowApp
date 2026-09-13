import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/insurflow_brand_mark.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated
        ? authState.session.greetingName(fallback: strings.fieldAdjuster)
        : strings.fieldAdjuster;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: context.spaceSymmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              InsurFlowBrandMark(size: context.width(64)),
              context.addVerticalSpace(16),
              Text(
                name,
                style: context.font22Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
              context.addVerticalSpace(6),
              Text(
                strings.fieldAdjuster,
                style: context.font14Regular?.copyWith(
                  color: colors.textSecondaryColor,
                ),
              ),
              const Spacer(),
              AppOutlinedButton(
                label: strings.signOut,
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
