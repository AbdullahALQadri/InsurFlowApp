import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.buttonTheme;
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: context.height(48),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryColor,
          side: BorderSide(color: theme.outlinedBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: context.circularRadius(theme.borderRadius),
          ),
        ),
        child: Text(
          label,
          style: context.font16Bold?.copyWith(
            color: colors.primaryColor,
            fontWeight: FontWeightHelper.bold,
          ),
        ),
      ),
    );
  }
}
