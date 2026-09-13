import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class ClaimsSearchField extends StatelessWidget {
  const ClaimsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.circularRadius(12);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: context.font16Regular?.copyWith(color: colors.textPrimaryColor),
      cursorColor: colors.primaryColor,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search claim, vehicle or plate',
        filled: true,
        fillColor: colors.cardColor,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: context.width(22),
          color: colors.textSecondaryColor,
        ),
        contentPadding: context.spaceSymmetric(vertical: 12, horizontal: 16),
        hintStyle: context.font14Regular?.copyWith(
          color: colors.textSecondaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.inputFocusedBorderColor),
        ),
      ),
    );
  }
}
