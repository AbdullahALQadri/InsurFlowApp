import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

/// Asks the adjuster whether they can take a claim that is waiting on
/// their acceptance.
///
/// Returns true only when they explicitly accept. Declining — or
/// dismissing the dialog — returns false and makes **no** API call; the
/// claim simply stays in PENDING_ACCEPTANCE.
///
/// Shape, radius and colours all come from the dialog theme, so it
/// follows light, dark and custom themes without any local styling.
class AssignmentAvailabilityDialog extends StatelessWidget {
  const AssignmentAvailabilityDialog({super.key, this.claimNumber});

  /// Shown so the adjuster knows which claim they are accepting. It is
  /// the backend's `claimNumber`, never reformatted.
  final String? claimNumber;

  static Future<bool> show(
    BuildContext context, {
    String? claimNumber,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AssignmentAvailabilityDialog(claimNumber: claimNumber),
    );
    // Tapping outside must not count as accepting.
    return accepted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final number = claimNumber?.trim();

    return AlertDialog(
      key: const Key('assignment-availability-dialog'),
      icon: Container(
        width: context.width(46),
        height: context.width(46),
        decoration: BoxDecoration(
          color: colors.primaryColor.changeOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.assignment_ind_outlined,
          color: colors.primaryColor,
          size: context.width(23),
        ),
      ),
      title: Text(
        strings.acceptAssignmentTitle,
        textAlign: TextAlign.center,
        style: context.font18Bold?.copyWith(
          color: colors.textPrimaryColor,
          fontWeight: FontWeightHelper.semiBold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.acceptAssignmentBody,
            textAlign: TextAlign.center,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
              height: 1.45,
            ),
          ),
          if (number != null && number.isNotEmpty) ...[
            context.addVerticalSpace(14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.iconBackgroundColor,
                borderRadius: context.circularRadius(context.radii.pill),
                border: Border.all(color: colors.borderColor),
              ),
              child: Padding(
                padding: context.spaceSymmetric(vertical: 8, horizontal: 14),
                child: Text(
                  number,
                  // Backend value: shown exactly as sent, and kept LTR
                  // so a claim number reads correctly under Arabic.
                  textDirection: TextDirection.ltr,
                  style: context.font16Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actionsPadding: context.spaceSymmetric(vertical: 8, horizontal: 12),
      actions: [
        TextButton(
          key: const Key('assignment-decline'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            strings.declineAssignment,
            style: context.font14Bold?.copyWith(
              color: colors.textSecondaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        TextButton(
          key: const Key('assignment-accept'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            strings.acceptAssignment,
            style: context.font14Bold?.copyWith(
              color: colors.primaryColor,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
        ),
      ],
    );
  }
}
