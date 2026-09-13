import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class ApiLoadingView extends StatelessWidget {
  const ApiLoadingView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: context.spaceHorizontal(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.width(28),
              height: context.width(28),
              child: CircularProgressIndicator(
                strokeWidth: context.width(2.4),
                color: colors.primaryColor,
              ),
            ),
            context.addVerticalSpace(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiErrorView extends StatelessWidget {
  const ApiErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: context.spaceHorizontal(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: context.width(36),
              color: colors.inputErrorBorderColor,
            ),
            context.addVerticalSpace(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.font16Regular?.copyWith(
                color: colors.textPrimaryColor,
                height: 1.4,
              ),
            ),
            context.addVerticalSpace(16),
            SizedBox(
              width: context.width(160),
              child: AppPrimaryButton(
                label: strings.retry,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiEmptyView extends StatelessWidget {
  const ApiEmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: context.spaceHorizontal(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.font16Regular?.copyWith(
            color: colors.textSecondaryColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
