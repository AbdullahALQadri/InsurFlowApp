import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

/// Final irreversible-submit confirmation.
///
/// Confirming calls POST /claims/{id}/submit from the Claim Validation screen.
class SubmitClaimConfirmationSheet extends StatelessWidget {
  const SubmitClaimConfirmationSheet({
    super.key,
    required this.claimNumber,
    this.onSubmit,
  });

  final String claimNumber;
  final VoidCallback? onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required String claimNumber,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.textPrimaryColor.changeOpacity(0.28),
      builder: (_) {
        return SubmitClaimConfirmationSheet(claimNumber: claimNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final lottieSize = context.isSmallScreen
        ? context.width(128)
        : context.width(148);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colors.cardColor,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                      width: context.width(36),
                      height: context.height(4),
                    ),
                  ),
                  context.addVerticalSpace(16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: ClaimStatusColors.submitted.changeOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: context.spaceAroundAll(8),
                      child: AppAssetHelper.lottieImage(
                        AppLotties.lottieClaimValidation,
                        width: lottieSize,
                        height: lottieSize,
                        repeat: false,
                        placeholderBuilder: SizedBox(
                          width: lottieSize,
                          height: lottieSize,
                        ),
                      ),
                    ),
                  ),
                  context.addVerticalSpace(16),
                  Text(
                    strings.submitClaimQuestion,
                    textAlign: TextAlign.center,
                    style: context.font22Bold?.copyWith(
                      color: colors.textPrimaryColor,
                      fontWeight: FontWeightHelper.bold,
                      height: 1.25,
                    ),
                  ),
                  context.addVerticalSpace(16),
                  _ClaimNumberCard(claimNumber: claimNumber),
                  context.addVerticalSpace(16),
                  Text(
                    strings.submitClaimOfficerExplain,
                    textAlign: TextAlign.center,
                    style: context.font16Regular?.copyWith(
                      color: colors.textSecondaryColor,
                      height: 1.45,
                    ),
                  ),
                  context.addVerticalSpace(12),
                  const _IrreversibleNote(),
                  context.addVerticalSpace(20),
                  AppPrimaryButton(
                    key: const Key('confirm-submit-claim'),
                    label: strings.submitClaim,
                    prominent: true,
                    onPressed: () {
                      if (onSubmit != null) {
                        onSubmit!();
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                  ),
                  context.addVerticalSpace(8),
                  AppOutlinedButton(
                    label: strings.cancel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  context.addVerticalSpace(4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClaimNumberCard extends StatelessWidget {
  const _ClaimNumberCard({required this.claimNumber});

  final String claimNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.iconBackgroundColor,
        borderRadius: context.circularRadius(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Text(
              strings.claimFieldLabel,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
              ),
            ),
            context.addHorizontalSpace(16),
            Expanded(
              child: Text(
                claimNumber,
                textAlign: TextAlign.end,
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IrreversibleNote extends StatelessWidget {
  const _IrreversibleNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final warning = ClaimStatusColors.correctionRequired;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: warning.changeOpacity(0.08),
        borderRadius: context.circularRadius(14),
        border: Border.all(color: warning.changeOpacity(0.22)),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 12, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: context.width(18),
              color: warning,
            ),
            context.addHorizontalSpace(10),
            Expanded(
              child: Text(
                strings.submitClaimLockNote,
                style: context.font14Regular?.copyWith(
                  color: colors.textPrimaryColor,
                  height: 1.4,
                  fontWeight: FontWeightHelper.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
