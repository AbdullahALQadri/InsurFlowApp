import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
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

/// Confirmation step for the vehicle, customer and policy returned by
/// `GET /vehicles/lookup`.
///
/// Confirming links all three to the claim through a single
/// `PUT /claims/{id}/vehicle`, which requires `vehicleId`, `policyId`,
/// `customerId` and `plateNumber`. When the lookup did not return those
/// ids there is nothing to link, so the button reports the failure
/// instead of advancing as if the claim had been updated.
class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({
    super.key,
    required this.result,
    this.onConfirm,
    this.onEdit,
  });

  final VehicleLookupResult result;
  final ValueChanged<VehicleLookupResult>? onConfirm;
  final VoidCallback? onEdit;

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();

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
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  var _isLinking = false;

  VehicleLookupResult get result => widget.result;

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
                  key: const Key('confirm-vehicle-information'),
                  label: strings.confirmInformation,
                  prominent: true,
                  isLoading: _isLinking,
                  onPressed: _isLinking ? null : _confirm,
                ),
                context.addVerticalSpace(10),
                AppOutlinedButton(
                  label: strings.edit,
                  onPressed: widget.onEdit ?? () => context.pop(),
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (widget.onConfirm != null) {
      widget.onConfirm!(result);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.of(context);

    // The lookup found no vehicle/policy/customer for this plate, so
    // there is nothing to link. Say so rather than moving on.
    if (!result.canLinkToClaim) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.vehicleLinkUnavailable)),
      );
      return;
    }

    setState(() => _isLinking = true);
    final outcome = await AppDependencies.instance.updateClaimVehicleUseCase(
      claimId: result.claimId,
      vehicleId: result.vehicleId!,
      policyId: result.policyId!,
      customerId: result.customerId!,
      plateNumber: result.licensePlate,
    );
    if (!mounted) return;
    setState(() => _isLinking = false);

    outcome.fold(
      (failure) => messenger.showSnackBar(
        SnackBar(content: Text(strings.messageFor(failure))),
      ),
      (_) {
        InspectionProgress.complete(result.claimId, InspectionStepId.vehicle);
        AccidentDetailsScreen.open(context, claimId: result.claimId);
      },
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
            result.makeModel ?? strings.notAvailable,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              height: 1.2,
            ),
          ),
          context.addVerticalSpace(10),
          Row(
            children: [
              if (result.year != null) ...[
                _MetaChip(label: '${result.year}'),
                if (result.color != null) context.addHorizontalSpace(8),
              ],
              if (result.color != null)
                _MetaChip(label: strings.vehicleColorLabel(result.color!)),
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
            result.customerName ?? strings.notAvailable,
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
                result.customerPhone ?? strings.notAvailable,
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
      trailing: result.isPolicyActive
          ? PolicyActiveBadge(
              label: strings.policyStatusLabel(result.policyStatus)!,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.policyNumber ?? strings.notAvailable,
            style: context.font22Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.bold,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          if (result.policyStart != null && result.policyEnd != null) ...[
            context.addVerticalSpace(12),
            Text(
              ClaimDateFormatter.dateRange(
                strings,
                result.policyStart!,
                result.policyEnd!,
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
