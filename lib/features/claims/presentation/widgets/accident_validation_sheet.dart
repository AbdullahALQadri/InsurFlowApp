import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';

class AccidentValidationSheet extends StatelessWidget {
  const AccidentValidationSheet({
    super.key,
    required this.draft,
    required this.issues,
    this.now,
  });

  final AccidentDetailsDraft draft;
  final Map<AccidentField, AccidentFieldIssue> issues;
  final DateTime? now;

  static Future<AccidentField?> show(
    BuildContext context, {
    required AccidentDetailsDraft draft,
    required Map<AccidentField, AccidentFieldIssue> issues,
    DateTime? now,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<AccidentField>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.textPrimaryColor.changeOpacity(0.28),
      builder: (_) {
        return AccidentValidationSheet(draft: draft, issues: issues, now: now);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final lottieSize = context.isSmallScreen
        ? context.width(84)
        : context.width(96);
    final firstIssue = issues.keys.isEmpty ? null : issues.keys.first;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colors.cardColor,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.borderColor,
                    borderRadius: context.circularRadius(100),
                  ),
                  child: SizedBox(
                    width: context.width(40),
                    height: context.height(4),
                  ),
                ),
                context.addVerticalSpace(12),
                AppAssetHelper.lottieImage(
                  AppLotties.lottieAccidentWarning,
                  width: lottieSize,
                  height: lottieSize,
                  placeholderBuilder: SizedBox(
                    width: lottieSize,
                    height: lottieSize,
                  ),
                ),
                context.addVerticalSpace(4),
                Text(
                  strings.almostThere,
                  textAlign: TextAlign.center,
                  style: context.font22Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.bold,
                    height: 1.2,
                  ),
                ),
                context.addVerticalSpace(8),
                Text(
                  strings.completeMissingAccidentInfo,
                  textAlign: TextAlign.center,
                  style: context.font16Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
                context.addVerticalSpace(18),
                AccidentValidationChecklist(
                  draft: draft,
                  now: now,
                  onSelect: (field) => Navigator.of(context).pop(field),
                ),
                context.addVerticalSpace(20),
                AppPrimaryButton(
                  label: strings.completeDetails,
                  prominent: true,
                  onPressed: () => Navigator.of(context).pop(firstIssue),
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccidentValidationChecklist extends StatelessWidget {
  const AccidentValidationChecklist({
    super.key,
    required this.draft,
    this.now,
    this.onSelect,
  });

  final AccidentDetailsDraft draft;
  final DateTime? now;
  final ValueChanged<AccidentField>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in AccidentField.values) ...[
          _ChecklistRow(
            field: field,
            complete: draft.isComplete(field, now: now),
            onTap: onSelect == null ? null : () => onSelect!(field),
          ),
          if (field != AccidentField.damage) context.addVerticalSpace(8),
        ],
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.field,
    required this.complete,
    this.onTap,
  });

  final AccidentField field;
  final bool complete;
  final VoidCallback? onTap;

  static const _warning = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final label = strings.accidentChecklistLabel(field);

    return Material(
      color: complete ? colors.backgroundColor : _warning.changeOpacity(0.08),
      borderRadius: context.circularRadius(14),
      child: InkWell(
        key: Key('accident-check-${field.name}'),
        onTap: complete ? null : onTap,
        borderRadius: context.circularRadius(14),
        child: Padding(
          padding: context.spaceSymmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.font16Regular?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: complete
                        ? FontWeightHelper.medium
                        : FontWeightHelper.semiBold,
                  ),
                ),
              ),
              Text(
                complete ? '✓' : '⚠',
                style: context.font16Bold?.copyWith(
                  color: complete ? ClaimStatusColors.approved : _warning,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
