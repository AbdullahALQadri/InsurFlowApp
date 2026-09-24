import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_schemes.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_button_theme.dart';
import 'package:insurflow/core/global/design_system/tokens/app_metrics.dart';

/// Builds every theme the app can run with.
///
/// Light, dark and custom all go through the same [_build], so a
/// component theme added once applies to all three. Nothing here reads a
/// hex literal: colours come from [AppColorSchemes], and sizes from
/// [AppSpacing] / [AppRadii].
class AppTheme {
  AppTheme._();

  static const String _defaultFont = '';

  // --- Typography --------------------------------------------------------

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeight,
    required Color textColor,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      fontFamily: _defaultFont,
      height: lineHeight / fontSize,
    );
  }

  /// The type ramp, read through the `context.fontNN*` extensions.
  static TextTheme buildTextTheme({required Color textColor}) {
    TextStyle create(double size, FontWeight weight, double lineHeight) {
      return _style(
        fontSize: size,
        fontWeight: weight,
        lineHeight: lineHeight,
        textColor: textColor,
      );
    }

    return TextTheme(
      displayLarge: create(34, FontWeightHelper.bold, 40),
      displayMedium: create(34, FontWeightHelper.regular, 40),
      displaySmall: create(28, FontWeightHelper.bold, 32),
      headlineLarge: create(28, FontWeightHelper.regular, 32),
      headlineMedium: create(26, FontWeightHelper.bold, 30),
      headlineSmall: create(26, FontWeightHelper.regular, 30),
      titleLarge: create(22, FontWeightHelper.bold, 28),
      titleMedium: create(22, FontWeightHelper.regular, 28),
      titleSmall: create(18, FontWeightHelper.bold, 24),
      bodyLarge: create(18, FontWeightHelper.regular, 24),
      bodyMedium: create(16, FontWeightHelper.bold, 24),
      bodySmall: create(16, FontWeightHelper.regular, 24),
      labelLarge: create(14, FontWeightHelper.bold, 20),
      labelMedium: create(14, FontWeightHelper.regular, 20),
    );
  }

  // --- Buttons -----------------------------------------------------------

  /// Derived from the scheme so a custom accent reaches the primary
  /// button gradient too, instead of it staying brand cyan.
  static AppButtonTheme buttonThemeFor(AppColors colors) {
    return AppButtonTheme(
      backgroundGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _lighten(colors.primaryColor, 0.06),
          _darken(colors.primaryColor, 0.10),
        ],
      ),
      foregroundColor: colors.onPrimaryColor,
      disabledBackgroundColor: Color.alphaBlend(
        colors.textSecondaryColor.withValues(alpha: 0.35),
        colors.backgroundColor,
      ),
      disabledForegroundColor: colors.onPrimaryColor.withValues(alpha: 0.85),
      outlinedForegroundColor: colors.primaryColor,
      outlinedDisabledForegroundColor: colors.textSecondaryColor,
      outlinedBorderColor: colors.primaryColor,
      outlinedDisabledBorderColor: colors.borderColor,
      outlinedBorderWidth: 1,
      iconSize: 12,
      height: 42,
      borderRadius: AppRadii.standard.pill,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      iconSpacing: 10,
      loadingIndicatorSize: 24,
      loadingStrokeWidth: 2.5,
    );
  }

  // --- Public entry points ------------------------------------------------

  static ThemeData get lightTheme => _build(AppColorSchemes.light, Brightness.light);

  static ThemeData get darkTheme => _build(AppColorSchemes.dark, Brightness.dark);

  /// A theme accented with the user's chosen colour. See
  /// [AppColorSchemes.custom] for how the accent is kept legible.
  static ThemeData custom({
    required Color accent,
    required Brightness brightness,
  }) {
    return _build(
      AppColorSchemes.custom(accent: accent, brightness: brightness),
      brightness,
    );
  }

  // --- Builder ------------------------------------------------------------

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final buttons = buttonThemeFor(colors);
    final radii = AppRadii.standard;
    final spacing = AppSpacing.standard;
    final elevation = AppElevation(shadowColor: colors.shadowColor);
    final textTheme = buildTextTheme(textColor: colors.textPrimaryColor);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      extensions: [colors, buttons, spacing, radii, elevation],
      fontFamily: _defaultFont,
      primaryColor: colors.primaryColor,
      scaffoldBackgroundColor: colors.backgroundColor,
      canvasColor: colors.backgroundColor,
      cardColor: colors.cardColor,
      dividerColor: colors.borderColor,
      shadowColor: colors.shadowColor,
      splashColor: colors.primaryColor.withValues(alpha: 0.10),
      highlightColor: colors.primaryColor.withValues(alpha: 0.06),
      disabledColor: colors.textSecondaryColor.withValues(alpha: 0.5),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primaryColor,
        onPrimary: colors.onPrimaryColor,
        secondary: colors.primaryColor,
        onSecondary: colors.onPrimaryColor,
        error: colors.dangerColor,
        onError: colors.onStatusColor,
        surface: colors.cardColor,
        onSurface: colors.textPrimaryColor,
        surfaceContainerHighest: colors.selectedBackgroundColor,
        outline: colors.borderColor,
        shadow: colors.shadowColor,
        scrim: colors.overlayScrim,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textPrimaryColor),
      primaryIconTheme: IconThemeData(color: colors.onPrimaryColor),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.textPrimaryColor,
        surfaceTintColor: Colors.transparent,
        elevation: elevation.none,
        scrolledUnderElevation: elevation.none,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimaryColor),
        titleTextStyle: textTheme.titleSmall?.copyWith(
          color: colors.textPrimaryColor,
          fontWeight: FontWeightHelper.semiBold,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: elevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.card),
          side: BorderSide(color: colors.borderColor),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.borderColor,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: elevation.high,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.dialog),
        ),
        titleTextStyle: textTheme.titleSmall?.copyWith(
          color: colors.textPrimaryColor,
          fontWeight: FontWeightHelper.semiBold,
        ),
        contentTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.textSecondaryColor,
          height: 1.45,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.cardColor,
        modalBarrierColor: colors.overlayScrim,
        elevation: elevation.high,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radii.sheet),
          ),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.cardColor,
        selectedItemColor: colors.primaryColor,
        unselectedItemColor: colors.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: elevation.none,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.cardColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryColor.withValues(alpha: 0.14),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primaryColor
                : colors.textSecondaryColor,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? colors.selectedBackgroundColor
            : colors.textPrimaryColor,
        contentTextStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? colors.textPrimaryColor : colors.cardColor,
        ),
        actionTextColor: colors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.md),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondaryColor,
        textColor: colors.textPrimaryColor,
        selectedColor: colors.primaryColor,
        selectedTileColor: colors.selectedBackgroundColor,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.iconBackgroundColor,
        selectedColor: colors.primaryColor.withValues(alpha: 0.16),
        side: BorderSide(color: colors.borderColor),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.textPrimaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.pill),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryColor,
        linearTrackColor: colors.borderColor,
        circularTrackColor: Colors.transparent,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimaryColor
              : colors.cardColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryColor
              : colors.inputBorderColor,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryColor
              : colors.inputBorderColor,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryColor
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(colors.onPrimaryColor),
        side: BorderSide(color: colors.inputBorderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.xs / 2),
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primaryColor,
        selectionColor: colors.primaryColor.withValues(alpha: 0.24),
        selectionHandleColor: colors.primaryColor,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.textPrimaryColor,
          borderRadius: BorderRadius.circular(radii.xs),
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: colors.cardColor),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryColor,
          foregroundColor: buttons.foregroundColor,
          disabledBackgroundColor: buttons.disabledBackgroundColor,
          disabledForegroundColor: buttons.disabledForegroundColor,
          minimumSize: Size(double.infinity, buttons.height),
          padding: buttons.padding,
          elevation: elevation.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttons.borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttons.outlinedForegroundColor,
          disabledForegroundColor: buttons.outlinedDisabledForegroundColor,
          minimumSize: Size(double.infinity, buttons.height),
          padding: buttons.padding,
          side: BorderSide(
            color: buttons.outlinedBorderColor,
            width: buttons.outlinedBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttons.borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryColor,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.cardColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.field),
          borderSide: BorderSide(color: colors.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.field),
          borderSide: BorderSide(color: colors.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.field),
          borderSide: BorderSide(
            color: colors.inputFocusedBorderColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.field),
          borderSide: BorderSide(color: colors.inputErrorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.field),
          borderSide: BorderSide(
            color: colors.inputErrorBorderColor,
            width: 1.4,
          ),
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colors.textSecondaryColor,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.textSecondaryColor,
        ),
        errorStyle: textTheme.labelMedium?.copyWith(
          color: colors.inputErrorBorderColor,
        ),
      ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
