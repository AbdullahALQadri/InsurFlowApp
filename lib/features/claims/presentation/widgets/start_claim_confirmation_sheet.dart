import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';

class StartClaimConfirmationSheet extends StatelessWidget {
  const StartClaimConfirmationSheet({
    super.key,
    required this.claimNumber,
    required this.vehicle,
  });

  final String claimNumber;
  final String vehicle;

  static Future<void> show(
    BuildContext context, {
    required String claimNumber,
    required String vehicle,
  }) {
    final colors = context.colors;
    final bloc = context.read<ClaimDetailsBloc>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.textPrimaryColor.changeOpacity(0.28),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: StartClaimConfirmationSheet(
            claimNumber: claimNumber,
            vehicle: vehicle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final lottieSize = context.isSmallScreen
        ? context.width(96)
        : context.width(112);

    return BlocConsumer<ClaimDetailsBloc, ClaimDetailsState>(
      listener: (context, state) {
        if (state is ClaimDetailsStarted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isStarting = state is ClaimDetailsLoadSuccess && state.isStarting;
        final startError = state is ClaimDetailsLoadSuccess
            ? state.startFailure
            : null;
        final errorText = startError == null
            ? null
            : strings.startMessageFor(startError);

        return PopScope(
          canPop: !isStarting,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Material(
              color: colors.cardColor,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: context.spaceSymmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
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
                            color: colors.primaryColor.changeOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: context.spaceAroundAll(6),
                            child: AppAssetHelper.lottieImage(
                              AppLotties.lottieStartInspection,
                              width: lottieSize,
                              height: lottieSize,
                              repeat: true,
                            ),
                          ),
                        ),
                        context.addVerticalSpace(16),
                        Text(
                          strings.startFieldInspectionTitle,
                          textAlign: TextAlign.center,
                          style: context.font22Bold?.copyWith(
                            color: colors.textPrimaryColor,
                            fontWeight: FontWeightHelper.bold,
                            height: 1.25,
                          ),
                        ),
                        context.addVerticalSpace(16),
                        _ClaimSummaryCard(
                          claimNumber: claimNumber,
                          vehicle: vehicle,
                        ),
                        context.addVerticalSpace(16),
                        Text(
                          strings.startInspectionExplain,
                          textAlign: TextAlign.center,
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                            height: 1.45,
                          ),
                        ),
                        if (errorText != null) ...[
                          context.addVerticalSpace(12),
                          Text(
                            errorText,
                            textAlign: TextAlign.center,
                            style: context.font14Regular?.copyWith(
                              color: colors.inputErrorBorderColor,
                            ),
                          ),
                        ],
                        context.addVerticalSpace(20),
                        AppPrimaryButton(
                          label: strings.startInspection,
                          prominent: true,
                          isLoading: isStarting,
                          onPressed: isStarting
                              ? null
                              : () => context.read<ClaimDetailsBloc>().add(
                                  const ClaimStartRequested(),
                                ),
                        ),
                        context.addVerticalSpace(8),
                        AppOutlinedButton(
                          label: strings.cancel,
                          onPressed: isStarting
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                        context.addVerticalSpace(4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClaimSummaryCard extends StatelessWidget {
  const _ClaimSummaryCard({required this.claimNumber, required this.vehicle});

  final String claimNumber;
  final String vehicle;

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
        child: Column(
          children: [
            _SummaryRow(label: strings.claimFieldLabel, value: claimNumber),
            context.addVerticalSpace(12),
            Divider(height: 1, color: colors.borderColor),
            context.addVerticalSpace(12),
            _SummaryRow(label: strings.vehicleFieldLabel, value: vehicle),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.width(72),
          child: Text(
            label,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.font16Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
