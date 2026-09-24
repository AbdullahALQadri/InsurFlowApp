import 'package:flutter/material.dart';

/// Spacing scale, in design units.
///
/// These are design-space numbers, passed through the responsive helpers
/// in `AppSizes` (`context.width`, `context.height`,
/// `context.spaceSymmetric`) exactly as raw numbers were before. Using
/// the scale keeps vertical rhythm consistent instead of each screen
/// inventing its own gaps.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.xxxl = 32,
    this.screenHorizontal = 20,
    this.screenVertical = 16,
    this.cardPadding = 16,
    this.sectionGap = 12,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  /// Page gutters and card rhythm.
  final double screenHorizontal;
  final double screenVertical;
  final double cardPadding;
  final double sectionGap;

  static const AppSpacing standard = AppSpacing();

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? screenHorizontal,
    double? screenVertical,
    double? cardPadding,
    double? sectionGap,
  }) {
    return AppSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      screenHorizontal: screenHorizontal ?? this.screenHorizontal,
      screenVertical: screenVertical ?? this.screenVertical,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionGap: sectionGap ?? this.sectionGap,
    );
  }

  /// Spacing does not animate between themes.
  @override
  AppSpacing lerp(covariant AppSpacing? other, double t) => other ?? this;
}

/// Corner-radius scale, in design units.
///
/// Pass through `context.circularRadius(...)` so radii scale with the
/// device the same way spacing does.
@immutable
class AppRadii extends ThemeExtension<AppRadii> {
  const AppRadii({
    this.xs = 8,
    this.sm = 10,
    this.md = 12,
    this.lg = 14,
    this.xl = 16,
    this.xxl = 20,
    this.pill = 100,
    this.card = 16,
    this.field = 12,
    this.sheet = 20,
    this.dialog = 18,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double pill;

  /// Component defaults.
  final double card;
  final double field;
  final double sheet;
  final double dialog;

  static const AppRadii standard = AppRadii();

  @override
  AppRadii copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? pill,
    double? card,
    double? field,
    double? sheet,
    double? dialog,
  }) {
    return AppRadii(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      pill: pill ?? this.pill,
      card: card ?? this.card,
      field: field ?? this.field,
      sheet: sheet ?? this.sheet,
      dialog: dialog ?? this.dialog,
    );
  }

  @override
  AppRadii lerp(covariant AppRadii? other, double t) => other ?? this;
}

/// Shadow scale.
///
/// [shadowColor] follows the theme, so elevation reads correctly on a
/// dark surface instead of a light-theme shadow being painted onto it.
@immutable
class AppElevation extends ThemeExtension<AppElevation> {
  const AppElevation({
    required this.shadowColor,
    this.none = 0,
    this.low = 2,
    this.medium = 8,
    this.high = 16,
  });

  final Color shadowColor;
  final double none;
  final double low;
  final double medium;
  final double high;

  /// Soft shadow used by raised cards and sheets.
  List<BoxShadow> card({
    double opacity = 0.06,
    double blur = 20,
    double dy = 8,
  }) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, dy),
      ),
    ];
  }

  @override
  AppElevation copyWith({
    Color? shadowColor,
    double? none,
    double? low,
    double? medium,
    double? high,
  }) {
    return AppElevation(
      shadowColor: shadowColor ?? this.shadowColor,
      none: none ?? this.none,
      low: low ?? this.low,
      medium: medium ?? this.medium,
      high: high ?? this.high,
    );
  }

  @override
  AppElevation lerp(covariant AppElevation? other, double t) {
    if (other == null) return this;
    return AppElevation(
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      none: none,
      low: low,
      medium: medium,
      high: high,
    );
  }
}
