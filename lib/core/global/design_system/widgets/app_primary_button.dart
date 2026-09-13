import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.prominent = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool prominent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.buttonTheme;
    final enabled = onPressed != null && !isLoading;
    final height = context.height(prominent ? 54 : 48);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? theme.backgroundGradient : null,
          color: enabled ? null : theme.disabledBackgroundColor,
          borderRadius: context.circularRadius(theme.borderRadius),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: context.circularRadius(theme.borderRadius),
            child: Padding(
              padding: context.spaceHorizontal(16),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: context.width(theme.loadingIndicatorSize),
                        height: context.width(theme.loadingIndicatorSize),
                        child: CircularProgressIndicator(
                          strokeWidth: theme.loadingStrokeWidth,
                          color: theme.foregroundColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: context.width(20),
                              color: enabled
                                  ? theme.foregroundColor
                                  : theme.disabledForegroundColor,
                            ),
                            context.addHorizontalSpace(8),
                          ],
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                maxLines: 1,
                                style: context.font16Bold?.copyWith(
                                  color: enabled
                                      ? theme.foregroundColor
                                      : theme.disabledForegroundColor,
                                  fontWeight: FontWeightHelper.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
