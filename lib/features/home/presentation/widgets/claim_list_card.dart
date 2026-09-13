import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_status_badge.dart';

class ClaimListCard extends StatelessWidget {
  const ClaimListCard({
    super.key,
    required this.claim,
    required this.onViewClaim,
  });

  final ClaimPreview claim;
  final VoidCallback onViewClaim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.cardColor,
      borderRadius: context.circularRadius(16),
      child: InkWell(
        onTap: onViewClaim,
        borderRadius: context.circularRadius(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: context.circularRadius(16),
            border: Border.all(color: colors.borderColor),
          ),
          child: Padding(
            padding: context.spaceSymmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        claim.displayNumber,
                        style: context.font16Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.bold,
                        ),
                      ),
                    ),
                    ClaimStatusBadge(status: claim.status),
                  ],
                ),
                context.addVerticalSpace(10),
                Text(
                  claim.vehicle,
                  style: context.font16Regular?.copyWith(
                    color: colors.textPrimaryColor,
                  ),
                ),
                context.addVerticalSpace(4),
                Text(
                  claim.licensePlate,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                context.addVerticalSpace(12),
                _MetaRow(
                  icon: Icons.location_on_outlined,
                  value: claim.location,
                ),
                context.addVerticalSpace(6),
                _MetaRow(
                  icon: Icons.schedule_outlined,
                  value: 'Updated ${_relativeTime(claim.lastUpdated)}',
                ),
                context.addVerticalSpace(14),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: onViewClaim,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primaryColor,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: context.spaceSymmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    child: Text(
                      'View Claim',
                      style: context.font14Bold?.copyWith(
                        color: colors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(
          icon,
          size: context.width(16),
          color: colors.textSecondaryColor,
        ),
        context.addHorizontalSpace(6),
        Expanded(
          child: Text(
            value,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
