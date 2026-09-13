import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.enabled = true,
    this.hasError = false,
    this.errorText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.suffix,
    this.onSubmitted,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool enabled;
  final bool hasError;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.circularRadius(12);
    final borderColor = hasError
        ? colors.inputErrorBorderColor
        : colors.inputBorderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font14Bold?.copyWith(
            color: colors.textPrimaryColor,
          ),
        ),
        context.addVerticalSpace(8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: context.font16Regular?.copyWith(
            color: colors.textPrimaryColor,
          ),
          cursorColor: colors.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.cardColor,
            errorText: errorText,
            errorMaxLines: 2,
            suffixIcon: suffix,
            contentPadding: context.spaceSymmetric(
              vertical: 14,
              horizontal: 16,
            ),
            hintStyle: context.font16Regular?.copyWith(
              color: colors.textSecondaryColor,
            ),
            errorStyle: context.font14Regular?.copyWith(
              color: colors.inputErrorBorderColor,
            ),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: hasError
                    ? colors.inputErrorBorderColor
                    : colors.inputFocusedBorderColor,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: colors.inputErrorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: colors.inputErrorBorderColor,
                width: 1.4,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }
}
