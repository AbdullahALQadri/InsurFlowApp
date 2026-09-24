import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class AssignmentInfoCard extends StatelessWidget {
  const AssignmentInfoCard({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.font14Bold?.copyWith(
                color: colors.primaryColor,
                letterSpacing: 1.1,
                fontWeight: FontWeightHelper.semiBold,
                fontSize: context.width(11),
              ),
            ),
            context.addVerticalSpace(10),
            child,
          ],
        ),
      ),
    );
  }
}

class AssignmentInfoLines extends StatelessWidget {
  const AssignmentInfoLines({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) context.addVerticalSpace(4),
          Text(
            lines[i],
            style: (i == 0 ? context.font16Bold : context.font14Regular)
                ?.copyWith(
                  color: i == 0
                      ? colors.textPrimaryColor
                      : colors.textSecondaryColor,
                  fontWeight: i == 0 ? FontWeightHelper.semiBold : null,
                  height: 1.35,
                ),
          ),
        ],
      ],
    );
  }
}

/// A `label / value` pair inside an [AssignmentInfoCard].
///
/// Renders only when the backend actually sent [value]; a null or blank
/// value means the field was never captured, and the caller decides
/// whether to omit the row or show the section's own empty note.
class AssignmentInfoRow extends StatelessWidget {
  const AssignmentInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  bool get hasValue =>
      valueWidget != null || (value?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    if (!hasValue) return const SizedBox.shrink();
    final colors = context.colors;

    return Padding(
      padding: context.spaceBottom(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
              fontSize: context.width(12),
            ),
          ),
          context.addVerticalSpace(2),
          valueWidget ??
              Text(
                value!.trim(),
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  height: 1.35,
                ),
              ),
        ],
      ),
    );
  }
}

/// Shown inside a section whose backend data is still null, so the
/// screen states the fact instead of rendering a fabricated value.
class AssignmentEmptyNote extends StatelessWidget {
  const AssignmentEmptyNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      message,
      style: context.font14Regular?.copyWith(
        color: colors.textSecondaryColor,
        height: 1.4,
      ),
    );
  }
}
