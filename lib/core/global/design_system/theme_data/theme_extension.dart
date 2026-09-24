import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_button_theme.dart';
import 'package:insurflow/core/global/design_system/tokens/app_metrics.dart';

/// Access to the design tokens from any widget.
///
/// Every colour, radius, spacing step and shadow the UI draws should
/// come from here rather than from a literal, so a theme change reaches
/// the whole app.
extension ThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppButtonTheme get buttonTheme => Theme.of(this).extension<AppButtonTheme>()!;

  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? AppSpacing.standard;

  AppRadii get radii => Theme.of(this).extension<AppRadii>() ?? AppRadii.standard;

  AppElevation get elevation =>
      Theme.of(this).extension<AppElevation>() ??
      AppElevation(shadowColor: colors.shadowColor);

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
