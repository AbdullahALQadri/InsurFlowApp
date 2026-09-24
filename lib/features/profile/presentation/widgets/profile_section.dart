import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

/// A titled card, matching the section cards used across the claims
/// screens so Profile reads as part of the same app.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visible = children.whereType<Widget>().toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.spaceSymmetric(vertical: 0, horizontal: 4),
          child: Text(
            label,
            style: context.font14Bold?.copyWith(
              color: colors.primaryColor,
              letterSpacing: 1.1,
              fontWeight: FontWeightHelper.semiBold,
              fontSize: context.width(11),
            ),
          ),
        ),
        context.addVerticalSpace(8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: context.circularRadius(16),
            border: Border.all(color: colors.borderColor),
          ),
          child: Column(children: visible),
        ),
      ],
    );
  }
}

/// A single read-only fact about the signed-in user.
///
/// [value] is whatever the backend returned. When it is null the row
/// still renders, stating that the backend did not provide it, rather
/// than showing a fabricated value — but callers usually omit the row
/// entirely instead (see [ProfileRow.ifPresent]).
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  /// Returns null when the backend sent nothing, so the caller can drop
  /// the row from the section.
  static ProfileRow? ifPresent({
    Key? key,
    required IconData icon,
    required String label,
    required String? value,
    bool isLast = false,
  }) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return ProfileRow(
      key: key,
      icon: icon,
      label: label,
      value: text,
      isLast: isLast,
    );
  }

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Padding(
      padding: context.spaceSymmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: context.width(34),
            height: context.width(34),
            decoration: BoxDecoration(
              color: colors.iconBackgroundColor,
              borderRadius: context.circularRadius(10),
            ),
            child: Icon(
              icon,
              size: context.width(17),
              color: colors.primaryColor,
            ),
          ),
          context.addHorizontalSpace(12),
          Expanded(
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
                if (value != null) ...[
                  context.addVerticalSpace(2),
                  Text(
                    value!,
                    style: context.font16Bold?.copyWith(
                      color: colors.textPrimaryColor,
                      fontWeight: FontWeightHelper.semiBold,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            context.addHorizontalSpace(10),
            trailing!,
          ] else if (onTap != null) ...[
            context.addHorizontalSpace(10),
            Icon(
              Icons.chevron_right_rounded,
              size: context.width(20),
              color: colors.textSecondaryColor,
            ),
          ],
        ],
      ),
    );

    return Column(
      children: [
        if (onTap == null)
          content
        else
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, child: content),
          ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: context.width(62),
            color: colors.borderColor,
          ),
      ],
    );
  }
}
