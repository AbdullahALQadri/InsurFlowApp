import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/policy_active_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/stylized_license_plate.dart';
import 'package:insurflow/features/claims/presentation/widgets/verified_lookup_card.dart';

class VehicleInformationScreen extends StatelessWidget {
  const VehicleInformationScreen({
    super.key,
    required this.result,
    this.onConfirm,
    this.onEdit,
  });

  final VehicleLookupResult result;
  final ValueChanged<VehicleLookupResult>? onConfirm;
  final VoidCallback? onEdit;

  static Future<dynamic> open(
    BuildContext context, {
    required VehicleLookupResult result,
    bool replace = false,
  }) {
    if (replace) {
      return context.pushReplacementNamed(
        Routes.vehicleInformationScreen,
        arguments: result,
      );
    }
    return context.pushNamed(
      Routes.vehicleInformationScreen,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(result.claimId),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.vehicleInformation,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _VehicleCard(result: result),
                      context.addVerticalSpace(16),
                      _CustomerCard(result: result),
                      context.addVerticalSpace(16),
                      _PolicyCard(result: result),
                      context.addVerticalSpace(12),
                    ],
                  ),
                ),
                AppPrimaryButton(
                  label: strings.confirmInformation,
                  prominent: true,
                  onPressed: () {
                    if (onConfirm != null) {
                      onConfirm!(result);
                      return;
                    }
                    InspectionProgress.complete(
                      result.claimId,
                      InspectionStepId.vehicle,
                    );
                    AccidentDetailsScreen.open(
                      context,
                      claimId: result.claimId,
                    );
                  },
                ),
                context.addVerticalSpace(10),
                AppOutlinedButton(
                  label: strings.edit,
                  onPressed: onEdit ?? () => context.pop(),
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

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.result});

  final VehicleLookupResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return VerifiedLookupCard(
      label: strings.vehicleSection,
      icon: Icons.directions_car_outlined,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.hasVehicle
                ? result.makeModel
                : AppStrings.of(context).notAvailable,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              height: 1.2,
            ),
          ),
          context.addVerticalSpace(10),
          Row(
            children: [
              if (result.year > 0) ...[
                _MetaChip(label: '${result.year}'),
                if (result.colorKey.trim().isNotEmpty)
                  context.addHorizontalSpace(8),
              ],
              if (result.colorKey.trim().isNotEmpty)
                _MetaChip(label: strings.vehicleColorLabel(result.colorKey)),
            ],
          ),
          context.addVerticalSpace(18),
          Text(
            strings.licensePlateLabel,
            style: context.font14Regular?.copyWith(
              color: colors.textSecondaryColor,
              fontWeight: FontWeightHelper.medium,
            ),
          ),
          context.addVerticalSpace(8),
          Text(
            result.licensePlate,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              letterSpacing: 1.8,
              height: 1.1,
            ),
          ),
          context.addVerticalSpace(14),
          StylizedLicensePlate(
            plateNumber: result.licensePlate,
            height: context.height(56),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.result});

  final VehicleLookupResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return VerifiedLookupCard(
      label: strings.customerSection,
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.hasCustomer
                ? result.customerName
                : AppStrings.of(context).notAvailable,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              height: 1.25,
            ),
          ),
          context.addVerticalSpace(8),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: context.width(16),
                color: colors.textSecondaryColor,
              ),
              context.addHorizontalSpace(8),
              Text(
                result.customerPhone.trim().isEmpty
                    ? AppStrings.of(context).notAvailable
                    : result.customerPhone,
                style: context.font16Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.result});

  final VehicleLookupResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return VerifiedLookupCard(
      label: strings.policySection,
      icon: Icons.verified_user_outlined,
      watermark: Icons.shield_outlined,
      trailing: result.policyStatus == PolicyStatus.active
          ? PolicyActiveBadge(
              label: strings.policyStatusLabel(result.policyStatus),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.hasPolicy
                ? result.policyNumber
                : AppStrings.of(context).notAvailable,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          if (result.policyStart.millisecondsSinceEpoch > 0 &&
              result.policyEnd.millisecondsSinceEpoch > 0) ...[
            context.addVerticalSpace(12),
            Text(
              ClaimDateFormatter.dateRange(
                result.policyStart,
                result.policyEnd,
              ),
              style: context.font16Regular?.copyWith(
                color: colors.textSecondaryColor,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: context.circularRadius(100),
        border: Border.all(color: colors.borderColor),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 6, horizontal: 12),
        child: Text(
          label,
          style: context.font14Bold?.copyWith(
            color: colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
      ),
    );
  }
}
