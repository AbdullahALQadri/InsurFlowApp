import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';
import 'package:insurflow/features/home/presentation/screens/home_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claims_list_screen.dart';
import 'package:insurflow/features/home/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _goToProfile() => setState(() => _index = 2);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final pages = [
      HomeScreen(onAvatarTap: _goToProfile),
      const ClaimsListScreen(),
      const ProfileScreen(),
    ];

    return BlocProvider(
      create: (_) => AppDependencies.instance.createClaimsBloc()
        ..add(const ClaimsRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous is AuthAuthenticated && current is AuthUnauthenticated,
        listener: (context, state) {
          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (_) => false,
          );
        },
        child: Scaffold(
          backgroundColor: colors.backgroundColor,
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.cardColor,
              border: Border(top: BorderSide(color: colors.borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: context.height(60),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: strings.homeTitle,
                      selected: _index == 0,
                      onTap: () => setState(() => _index = 0),
                    ),
                    _NavItem(
                      icon: Icons.assignment_outlined,
                      selectedIcon: Icons.assignment_rounded,
                      label: strings.myClaims,
                      selected: _index == 1,
                      onTap: () => setState(() => _index = 1),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person_rounded,
                      label: strings.profileTitle,
                      selected: _index == 2,
                      onTap: _goToProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primaryColor
        : context.colors.textSecondaryColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              size: context.width(22),
              color: color,
            ),
            context.addVerticalSpace(4),
            Text(
              label,
              style: context.font14Regular?.copyWith(
                color: color,
                fontSize: context.width(11),
                fontWeight: selected
                    ? FontWeightHelper.semiBold
                    : FontWeightHelper.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
