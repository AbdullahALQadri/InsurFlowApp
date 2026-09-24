import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';

/// Brand-surface colours for the splash screen.
///
/// Retained as the name the splash widgets already import; the values
/// now come from [AppPalette] so there is one source of truth. Screens
/// other than the splash should read the `brand*` tokens from
/// `context.colors` instead, which is what makes them themeable.
class AppSplashColors {
  AppSplashColors._();

  static const Color midnight = AppPalette.midnight;
  static const Color abyss = AppPalette.abyss;
  static const Color navy = AppPalette.navy;
  static const Color atmosphere = AppPalette.atmosphere;
  static const Color cyan = AppPalette.cyanLight;
  static const Color cyanDeep = AppPalette.cyanDeep;
  static const Color glow = AppPalette.glow;
  static const Color line = AppPalette.line;
  static const Color textPrimary = AppPalette.immersiveInk;
  static const Color textMuted = AppPalette.immersiveMuted;
  static const Color textSubtle = AppPalette.immersiveSubtle;
}
