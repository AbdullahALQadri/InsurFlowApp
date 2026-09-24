import 'package:flutter/material.dart';

/// Every colour the UI is allowed to use, as semantic tokens.
///
/// Read through `context.colors`. Widgets must not define colours of
/// their own — adding a hex literal to a widget is what makes a theme
/// switch miss a screen.
///
/// Three groups:
///
/// * **Surface / content / feedback** — follow the active theme and flip
///   between light, dark and custom.
/// * **Brand** — the dark navy identity used by splash, the login hero
///   and section headers. Held constant so the brand does not invert,
///   but still tokenised so it is swappable in one place.
/// * **Immersive** — surfaces drawn over a live camera feed (evidence
///   capture, plate scanner). Deliberately dark in every theme: a light
///   overlay on camera video is unreadable.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.inputBorderColor,
    required this.inputFocusedBorderColor,
    required this.inputErrorBorderColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.selectedBackgroundColor,
    required this.iconBackgroundColor,
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.dangerColor,
    required this.onStatusColor,
    required this.overlayScrim,
    required this.shadowColor,
    required this.brandSurfaceStart,
    required this.brandSurfaceEnd,
    required this.brandAtmosphere,
    required this.brandAccent,
    required this.brandAccentDeep,
    required this.brandGlow,
    required this.brandLine,
    required this.brandInk,
    required this.brandMuted,
    required this.immersiveSurface,
    required this.immersivePanel,
    required this.immersiveInk,
    required this.immersiveMuted,
    required this.immersiveSubtle,
    required this.immersiveScrim,
  });

  // --- Surfaces and content ----------------------------------------------

  final Color primaryColor;

  /// Text and icons drawn on top of [primaryColor]. Chosen for contrast,
  /// which matters most for a user-picked custom accent.
  final Color onPrimaryColor;

  final Color backgroundColor;
  final Color cardColor;

  final Color inputBorderColor;
  final Color inputErrorBorderColor;
  final Color inputFocusedBorderColor;

  final Color textPrimaryColor;
  final Color textSecondaryColor;

  final Color borderColor;
  final Color selectedBackgroundColor;
  final Color iconBackgroundColor;

  // --- Feedback ----------------------------------------------------------

  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Color dangerColor;

  /// Content drawn on a filled status colour.
  final Color onStatusColor;

  /// Modal barriers and image scrims.
  final Color overlayScrim;

  final Color shadowColor;

  // --- Brand -------------------------------------------------------------

  final Color brandSurfaceStart;
  final Color brandSurfaceEnd;
  final Color brandAtmosphere;
  final Color brandAccent;
  final Color brandAccentDeep;
  final Color brandGlow;
  final Color brandLine;
  final Color brandInk;
  final Color brandMuted;

  // --- Immersive (camera / scanner) --------------------------------------

  final Color immersiveSurface;
  final Color immersivePanel;
  final Color immersiveInk;
  final Color immersiveMuted;
  final Color immersiveSubtle;
  final Color immersiveScrim;

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? backgroundColor,
    Color? cardColor,
    Color? inputBorderColor,
    Color? inputErrorBorderColor,
    Color? inputFocusedBorderColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? borderColor,
    Color? selectedBackgroundColor,
    Color? iconBackgroundColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? dangerColor,
    Color? onStatusColor,
    Color? overlayScrim,
    Color? shadowColor,
    Color? brandSurfaceStart,
    Color? brandSurfaceEnd,
    Color? brandAtmosphere,
    Color? brandAccent,
    Color? brandAccentDeep,
    Color? brandGlow,
    Color? brandLine,
    Color? brandInk,
    Color? brandMuted,
    Color? immersiveSurface,
    Color? immersivePanel,
    Color? immersiveInk,
    Color? immersiveMuted,
    Color? immersiveSubtle,
    Color? immersiveScrim,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputErrorBorderColor:
          inputErrorBorderColor ?? this.inputErrorBorderColor,
      inputFocusedBorderColor:
          inputFocusedBorderColor ?? this.inputFocusedBorderColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      borderColor: borderColor ?? this.borderColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      dangerColor: dangerColor ?? this.dangerColor,
      onStatusColor: onStatusColor ?? this.onStatusColor,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      shadowColor: shadowColor ?? this.shadowColor,
      brandSurfaceStart: brandSurfaceStart ?? this.brandSurfaceStart,
      brandSurfaceEnd: brandSurfaceEnd ?? this.brandSurfaceEnd,
      brandAtmosphere: brandAtmosphere ?? this.brandAtmosphere,
      brandAccent: brandAccent ?? this.brandAccent,
      brandAccentDeep: brandAccentDeep ?? this.brandAccentDeep,
      brandGlow: brandGlow ?? this.brandGlow,
      brandLine: brandLine ?? this.brandLine,
      brandInk: brandInk ?? this.brandInk,
      brandMuted: brandMuted ?? this.brandMuted,
      immersiveSurface: immersiveSurface ?? this.immersiveSurface,
      immersivePanel: immersivePanel ?? this.immersivePanel,
      immersiveInk: immersiveInk ?? this.immersiveInk,
      immersiveMuted: immersiveMuted ?? this.immersiveMuted,
      immersiveSubtle: immersiveSubtle ?? this.immersiveSubtle,
      immersiveScrim: immersiveScrim ?? this.immersiveScrim,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColors(
      primaryColor: mix(primaryColor, other.primaryColor),
      onPrimaryColor: mix(onPrimaryColor, other.onPrimaryColor),
      backgroundColor: mix(backgroundColor, other.backgroundColor),
      cardColor: mix(cardColor, other.cardColor),
      inputBorderColor: mix(inputBorderColor, other.inputBorderColor),
      inputErrorBorderColor: mix(
        inputErrorBorderColor,
        other.inputErrorBorderColor,
      ),
      inputFocusedBorderColor: mix(
        inputFocusedBorderColor,
        other.inputFocusedBorderColor,
      ),
      textPrimaryColor: mix(textPrimaryColor, other.textPrimaryColor),
      textSecondaryColor: mix(textSecondaryColor, other.textSecondaryColor),
      borderColor: mix(borderColor, other.borderColor),
      selectedBackgroundColor: mix(
        selectedBackgroundColor,
        other.selectedBackgroundColor,
      ),
      iconBackgroundColor: mix(iconBackgroundColor, other.iconBackgroundColor),
      successColor: mix(successColor, other.successColor),
      warningColor: mix(warningColor, other.warningColor),
      infoColor: mix(infoColor, other.infoColor),
      dangerColor: mix(dangerColor, other.dangerColor),
      onStatusColor: mix(onStatusColor, other.onStatusColor),
      overlayScrim: mix(overlayScrim, other.overlayScrim),
      shadowColor: mix(shadowColor, other.shadowColor),
      brandSurfaceStart: mix(brandSurfaceStart, other.brandSurfaceStart),
      brandSurfaceEnd: mix(brandSurfaceEnd, other.brandSurfaceEnd),
      brandAtmosphere: mix(brandAtmosphere, other.brandAtmosphere),
      brandAccent: mix(brandAccent, other.brandAccent),
      brandAccentDeep: mix(brandAccentDeep, other.brandAccentDeep),
      brandGlow: mix(brandGlow, other.brandGlow),
      brandLine: mix(brandLine, other.brandLine),
      brandInk: mix(brandInk, other.brandInk),
      brandMuted: mix(brandMuted, other.brandMuted),
      immersiveSurface: mix(immersiveSurface, other.immersiveSurface),
      immersivePanel: mix(immersivePanel, other.immersivePanel),
      immersiveInk: mix(immersiveInk, other.immersiveInk),
      immersiveMuted: mix(immersiveMuted, other.immersiveMuted),
      immersiveSubtle: mix(immersiveSubtle, other.immersiveSubtle),
      immersiveScrim: mix(immersiveScrim, other.immersiveScrim),
    );
  }
}
