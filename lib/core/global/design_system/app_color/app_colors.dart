import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
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

  const AppColors({
    required this.primaryColor,
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
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
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
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
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
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;

    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      inputBorderColor: Color.lerp(
        inputBorderColor,
        other.inputBorderColor,
        t,
      )!,
      inputErrorBorderColor: Color.lerp(
        inputErrorBorderColor,
        other.inputErrorBorderColor,
        t,
      )!,
      inputFocusedBorderColor: Color.lerp(
        inputFocusedBorderColor,
        other.inputFocusedBorderColor,
        t,
      )!,
      textPrimaryColor: Color.lerp(
        textPrimaryColor,
        other.textPrimaryColor,
        t,
      )!,
      textSecondaryColor: Color.lerp(
        textSecondaryColor,
        other.textSecondaryColor,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      selectedBackgroundColor: Color.lerp(
        selectedBackgroundColor,
        other.selectedBackgroundColor,
        t,
      )!,
      iconBackgroundColor: Color.lerp(
        iconBackgroundColor,
        other.iconBackgroundColor,
        t,
      )!,
    );
  }
}
