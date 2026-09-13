import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class FieldWorkInput extends StatelessWidget {
  const FieldWorkInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
    this.required = false,
    this.errorText,
    this.attention = false,
    this.helperText,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.prefixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final String? errorText;
  final bool attention;
  final String? helperText;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final IconData? prefixIcon;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.circularRadius(14);
    const warning = Color(0xFFD97706);
    final borderColor = _hasError
        ? colors.inputErrorBorderColor
        : attention
        ? warning
        : colors.inputBorderColor;
    final fillColor = attention
        ? warning.changeOpacity(0.06)
        : colors.cardColor;
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: context.font14Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: context.font14Bold?.copyWith(
                  color: attention ? warning : colors.primaryColor,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
          ],
        ),
        context.addVerticalSpace(8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType:
              keyboardType ??
              (isMultiline ? TextInputType.multiline : TextInputType.text),
          textInputAction:
              textInputAction ??
              (isMultiline ? TextInputAction.newline : TextInputAction.next),
          style: context.font16Regular?.copyWith(
            color: colors.textPrimaryColor,
            height: 1.4,
          ),
          cursorColor: colors.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fillColor,
            errorText: errorText,
            errorMaxLines: 2,
            suffixIcon: suffix,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: colors.textSecondaryColor,
                    size: context.width(22),
                  ),
            contentPadding: context.spaceSymmetric(
              vertical: isMultiline ? 16 : 18,
              horizontal: 16,
            ),
            hintStyle: context.font16Regular?.copyWith(
              color: colors.textSecondaryColor,
              height: 1.4,
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
                color: _hasError
                    ? colors.inputErrorBorderColor
                    : attention
                    ? warning
                    : colors.inputFocusedBorderColor,
                width: 1.5,
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
                width: 1.5,
              ),
            ),
          ),
        ),
        if (!_hasError && helperText != null && helperText!.isNotEmpty) ...[
          context.addVerticalSpace(8),
          Text(
            helperText!,
            style: context.font14Regular?.copyWith(
              color: attention ? warning : colors.textSecondaryColor,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
