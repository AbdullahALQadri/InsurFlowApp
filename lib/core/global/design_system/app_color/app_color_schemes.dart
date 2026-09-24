import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';

/// Builds the three colour schemes the app ships with.
///
/// Light and dark are fixed. The custom scheme takes a user-chosen
/// accent and derives the rest, keeping the accent legible instead of
/// dropping it in unchecked.
class AppColorSchemes {
  AppColorSchemes._();

  // Brand and immersive tokens are repeated identically in both
  // schemes on purpose: the brand identity does not invert with the
  // theme, and camera overlays must stay dark whatever the user picked.

  static const AppColors light = AppColors(
    primaryColor: AppPalette.cyan,
    onPrimaryColor: AppPalette.white,
    backgroundColor: AppPalette.surfaceLight,
    cardColor: AppPalette.white,
    inputBorderColor: AppPalette.outlineLight,
    inputFocusedBorderColor: AppPalette.cyan,
    inputErrorBorderColor: AppPalette.danger,
    textPrimaryColor: AppPalette.inkLight,
    textSecondaryColor: AppPalette.mutedLight,
    borderColor: AppPalette.borderLight,
    selectedBackgroundColor: AppPalette.white,
    iconBackgroundColor: AppPalette.iconBackgroundLight,
    successColor: AppPalette.success,
    warningColor: AppPalette.warning,
    infoColor: AppPalette.info,
    dangerColor: AppPalette.danger,
    onStatusColor: AppPalette.white,
    overlayScrim: Color(0x8A000000),
    shadowColor: AppPalette.inkLight,
    brandSurfaceStart: AppPalette.navy,
    brandSurfaceEnd: AppPalette.midnight,
    brandAtmosphere: AppPalette.atmosphere,
    brandAccent: AppPalette.cyanLight,
    brandAccentDeep: AppPalette.cyanDeep,
    brandGlow: AppPalette.glow,
    brandLine: AppPalette.line,
    brandInk: AppPalette.immersiveInk,
    brandMuted: AppPalette.immersiveMuted,
    immersiveSurface: AppPalette.immersiveSurface,
    immersivePanel: AppPalette.immersivePanel,
    immersiveInk: AppPalette.immersiveInk,
    immersiveMuted: AppPalette.immersiveMuted,
    immersiveSubtle: AppPalette.immersiveSubtle,
    immersiveScrim: AppPalette.immersiveScrim,
  );

  static const AppColors dark = AppColors(
    primaryColor: AppPalette.cyanBright,
    onPrimaryColor: AppPalette.abyss,
    backgroundColor: AppPalette.surfaceDark,
    cardColor: AppPalette.cardDark,
    inputBorderColor: AppPalette.outlineDark,
    inputFocusedBorderColor: AppPalette.cyanBright,
    inputErrorBorderColor: Color(0xFFF87171),
    textPrimaryColor: AppPalette.inkDark,
    textSecondaryColor: AppPalette.mutedDark,
    borderColor: AppPalette.borderDark,
    selectedBackgroundColor: AppPalette.elevatedDark,
    iconBackgroundColor: AppPalette.elevatedDark,
    successColor: Color(0xFF2DD4BF),
    warningColor: Color(0xFFFBBF24),
    infoColor: Color(0xFF818CF8),
    dangerColor: Color(0xFFF87171),
    onStatusColor: AppPalette.abyss,
    overlayScrim: Color(0xB3000000),
    shadowColor: Colors.black,
    brandSurfaceStart: AppPalette.navy,
    brandSurfaceEnd: AppPalette.midnight,
    brandAtmosphere: AppPalette.atmosphere,
    brandAccent: AppPalette.cyanLight,
    brandAccentDeep: AppPalette.cyanDeep,
    brandGlow: AppPalette.glow,
    brandLine: AppPalette.line,
    brandInk: AppPalette.immersiveInk,
    brandMuted: AppPalette.immersiveMuted,
    immersiveSurface: AppPalette.immersiveSurface,
    immersivePanel: AppPalette.immersivePanel,
    immersiveInk: AppPalette.immersiveInk,
    immersiveMuted: AppPalette.immersiveMuted,
    immersiveSubtle: AppPalette.immersiveSubtle,
    immersiveScrim: AppPalette.immersiveScrim,
  );

  /// Accents offered in the custom-theme picker.
  ///
  /// Each is dark enough to carry white text on a light surface and is
  /// lightened automatically for dark mode by [custom].
  static const List<Color> presetAccents = [
    AppPalette.cyan,
    Color(0xFF2563EB), // blue
    Color(0xFF7C3AED), // violet
    Color(0xFF0F9D8A), // teal
    Color(0xFFD97706), // amber
    Color(0xFFDC2626), // red
    Color(0xFFDB2777), // pink
    Color(0xFF475569), // slate
  ];

  /// A scheme built around a user-chosen [accent].
  ///
  /// The accent is adjusted per brightness so it stays usable:
  /// * on light surfaces it is darkened until it reaches a readable
  ///   contrast against the card colour;
  /// * on dark surfaces it is lightened for the same reason;
  /// * [AppColors.onPrimaryColor] is then chosen as black or white,
  ///   whichever contrasts more with the final accent.
  ///
  /// Everything else inherits the matching light or dark scheme, so a
  /// custom theme is a re-accented light/dark theme rather than a third
  /// unmaintained palette.
  static AppColors custom({
    required Color accent,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? dark : light;

    final readableAccent = _readableOn(
      accent,
      background: base.cardColor,
      preferLighter: isDark,
    );

    return base.copyWith(
      primaryColor: readableAccent,
      onPrimaryColor: onColorFor(readableAccent),
      inputFocusedBorderColor: readableAccent,
      // Selection and icon chips pick up a tint of the accent so the
      // choice is visible beyond buttons alone.
      iconBackgroundColor: Color.alphaBlend(
        readableAccent.withValues(alpha: isDark ? 0.18 : 0.10),
        base.iconBackgroundColor,
      ),
      brandAccent: isDark ? readableAccent : _lighten(readableAccent, 0.12),
      brandAccentDeep: _darken(readableAccent, 0.18),
      brandGlow: _lighten(readableAccent, 0.32),
      brandLine: _lighten(readableAccent, 0.18),
    );
  }

  /// Black or white, whichever is more legible on [background].
  static Color onColorFor(Color background) {
    return _contrast(Colors.white, background) >=
            _contrast(Colors.black, background)
        ? Colors.white
        : Colors.black;
  }

  /// Nudges [color] until it reaches a 3:1 contrast against
  /// [background] — the WCAG minimum for large text, UI components and
  /// graphical objects, which is what an accent is used for.
  ///
  /// Gives up after a bounded number of steps so an extreme pick still
  /// returns something reasonable rather than looping.
  static Color _readableOn(
    Color color,
    {
    required Color background,
    required bool preferLighter,
  }) {
    const target = 3.0;
    var candidate = color;
    for (var i = 0; i < 24; i++) {
      if (_contrast(candidate, background) >= target) return candidate;
      candidate = preferLighter
          ? _lighten(candidate, 0.04)
          : _darken(candidate, 0.04);
    }
    return candidate;
  }

  /// WCAG relative-luminance contrast ratio, 1.0 to 21.0.
  static double _contrast(Color a, Color b) {
    final la = _relativeLuminance(a);
    final lb = _relativeLuminance(b);
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) => color.computeLuminance();

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Exposed for tests and for the accessibility check in the picker.
  static double contrastRatio(Color a, Color b) => _contrast(a, b);
}
