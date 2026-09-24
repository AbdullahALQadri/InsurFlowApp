import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';

/// Renders `timeline[]` from `GET /claims/{id}` — the claim's audit
/// trail, newest first.
///
/// Every entry has `action`, `performedBy`, `role` and `timestamp`.
/// `previousStatus` / `newStatus` are null on the "Claim Created" entry
/// and `notes` is null unless the actor left one, so each line is
/// rendered only when its value is present.
class ClaimTimelineView extends StatelessWidget {
  const ClaimTimelineView({super.key, required this.entries});

  final List<ClaimTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineTile(entry: entries[i], isLast: i == entries.length - 1),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry, required this.isLast});

  final ClaimTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final dotSize = context.width(10);

    final performer = entry.performedBy?.displayName;
    final role = strings.userRoleLabel(entry.role ?? entry.performedBy?.role);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                margin: EdgeInsets.only(top: context.height(5)),
                decoration: BoxDecoration(
                  color: colors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: EdgeInsets.symmetric(vertical: context.height(4)),
                    color: colors.borderColor,
                  ),
                ),
            ],
          ),
          context.addHorizontalSpace(12),
          Expanded(
            child: Padding(
              padding: context.spaceBottom(isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.action != null)
                    Text(
                      entry.action!,
                      style: context.font16Bold?.copyWith(
                        color: colors.textPrimaryColor,
                        fontWeight: FontWeightHelper.semiBold,
                        fontSize: context.width(14),
                      ),
                    ),
                  if (entry.hasStatusTransition) ...[
                    context.addVerticalSpace(2),
                    Text(
                      strings.statusTransitionLabel(
                        strings.claimStatusLabel(entry.previousStatus)!,
                        strings.claimStatusLabel(entry.newStatus)!,
                      ),
                      style: context.font14Regular?.copyWith(
                        color: colors.primaryColor,
                        fontSize: context.width(12),
                      ),
                    ),
                  ],
                  if (performer != null) ...[
                    context.addVerticalSpace(2),
                    Text(
                      role == null ? performer : '$performer · $role',
                      style: context.font14Regular?.copyWith(
                        color: colors.textSecondaryColor,
                        fontSize: context.width(12),
                      ),
                    ),
                  ],
                  if (entry.timestamp != null) ...[
                    context.addVerticalSpace(2),
                    Text(
                      ClaimDateFormatter.capturedAt(strings, entry.timestamp!),
                      style: context.font14Regular?.copyWith(
                        color: colors.textSecondaryColor,
                        fontSize: context.width(11),
                      ),
                    ),
                  ],
                  if (entry.notes?.trim().isNotEmpty ?? false) ...[
                    context.addVerticalSpace(6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.backgroundColor,
                        borderRadius: context.circularRadius(8),
                        border: Border.all(color: colors.borderColor),
                      ),
                      child: Padding(
                        padding: context.spaceSymmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Text(
                          entry.notes!.trim(),
                          style: context.font14Regular?.copyWith(
                            color: colors.textPrimaryColor,
                            height: 1.4,
                            fontSize: context.width(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
