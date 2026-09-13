import 'package:flutter/material.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_dark.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_light.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_button_theme.dart';

class AppTheme {
  static const String _defaultFont = '';

  // ---------------------------------------------------------------------------
  // Text Styles
  // ---------------------------------------------------------------------------

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

  static TextTheme _buildTextTheme({required Color textColor}) {
    TextStyle create(double size, FontWeight weight, double figmaLineHeight) {
      return _style(
        fontSize: size,
        fontWeight: weight,
        lineHeight: figmaLineHeight,
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

  // ---------------------------------------------------------------------------
  // Light Button Theme
  // ---------------------------------------------------------------------------

  static const AppButtonTheme lightButtonTheme = AppButtonTheme(
    backgroundGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF23B7DB), Color(0xFF0E8CBC)],
    ),

    foregroundColor: Colors.white,

    disabledBackgroundColor: Color(0xFFB9C8EA),
    disabledForegroundColor: Colors.white,
    outlinedForegroundColor: Color(0xFF00A3C4),
    outlinedDisabledForegroundColor: Color(0xFF9CA3AF),
    outlinedBorderColor: Color(0xFF00A3C4),
    outlinedDisabledBorderColor: Color(0xFFD1D5DB),
    outlinedBorderWidth: 1,
    iconSize: 12,
    height: 42,
    borderRadius: 100,

    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),

    iconSpacing: 10,

    loadingIndicatorSize: 24,
    loadingStrokeWidth: 2.5,
  );

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme {
    final colors = AppColorLight.colors;

    return ThemeData(
      brightness: Brightness.light,

      extensions: const [AppColorLight.colors, lightButtonTheme],

      fontFamily: _defaultFont,

      primaryColor: colors.primaryColor,
      scaffoldBackgroundColor: colors.backgroundColor,
      cardColor: colors.cardColor,

      colorScheme: ColorScheme.light(
        primary: colors.primaryColor,
        surface: colors.cardColor,
        onSurface: colors.textPrimaryColor,
        onSurfaceVariant: colors.textSecondaryColor,
      ),

      textTheme: _buildTextTheme(textColor: colors.textPrimaryColor),

      // -----------------------------------------------------------------------
      // Default Elevated Button
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          foregroundColor: lightButtonTheme.foregroundColor,
          minimumSize: Size(double.infinity, lightButtonTheme.height),
          padding: lightButtonTheme.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(lightButtonTheme.borderRadius),
          ),
          textStyle: _style(
            fontSize: 16,
            fontWeight: FontWeightHelper.bold,
            lineHeight: 24,
            textColor: lightButtonTheme.foregroundColor,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Outlined Button
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.primaryColor,
          minimumSize: Size(double.infinity, lightButtonTheme.height),
          padding: lightButtonTheme.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(lightButtonTheme.borderRadius),
          ),
          side: BorderSide(color: colors.primaryColor, width: 1),
          textStyle: _style(
            fontSize: 16,
            fontWeight: FontWeightHelper.bold,
            lineHeight: 24,
            textColor: colors.primaryColor,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Input
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.cardColor,
        isDense: true,

        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

        prefixIconConstraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),

        hintStyle: _buildTextTheme(
          textColor: colors.textSecondaryColor,
        ).labelMedium,

        labelStyle: _buildTextTheme(
          textColor: colors.textSecondaryColor,
        ).labelMedium,

        suffixIconColor: colors.textSecondaryColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputBorderColor),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputBorderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colors.inputFocusedBorderColor,
            width: 1,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputErrorBorderColor),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.inputErrorBorderColor),
        ),
      ),
    );
  }

  static const AppButtonTheme darkButtonTheme = AppButtonTheme(
    backgroundGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF23B7DB), Color(0xFF0E8CBC)],
    ),
    foregroundColor: Colors.white,
    disabledBackgroundColor: Color(0xFF334155),
    disabledForegroundColor: Color(0xFF94A3B8),
    outlinedForegroundColor: Color(0xFF22C3E0),
    outlinedDisabledForegroundColor: Color(0xFF64748B),
    outlinedBorderColor: Color(0xFF22C3E0),
    outlinedDisabledBorderColor: Color(0xFF334155),
    outlinedBorderWidth: 1,
    iconSize: 12,
    height: 42,
    borderRadius: 100,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    iconSpacing: 10,
    loadingIndicatorSize: 24,
    loadingStrokeWidth: 2.5,
  );

  static ThemeData get darkTheme {
    final colors = AppColorDark.colors;

    return ThemeData(
      brightness: Brightness.dark,
      extensions: const [AppColorDark.colors, darkButtonTheme],
      fontFamily: _defaultFont,
      primaryColor: colors.primaryColor,
      scaffoldBackgroundColor: colors.backgroundColor,
      cardColor: colors.cardColor,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryColor,
        surface: colors.cardColor,
        onSurface: colors.textPrimaryColor,
        onSurfaceVariant: colors.textSecondaryColor,
      ),
      textTheme: _buildTextTheme(textColor: colors.textPrimaryColor),
    );
  }
}
