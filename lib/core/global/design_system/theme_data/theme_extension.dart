import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_button_theme.dart';

extension ThemeExtension on BuildContext {
  AppColors get colors {
    return Theme.of(this).extension<AppColors>()!;
  }
  AppButtonTheme get buttonTheme {
    return Theme.of(this).extension<AppButtonTheme>()!;
  }
}
