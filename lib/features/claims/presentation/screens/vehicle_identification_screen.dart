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
import 'package:insurflow/features/claims/presentation/screens/license_plate_scanner_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/manual_plate_entry_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_scan_illustration.dart';

class VehicleIdentificationScreen extends StatelessWidget {
  const VehicleIdentificationScreen({
    super.key,
    required this.claimId,
    this.onScanPlate,
    this.onEnterManually,
  });

  final String claimId;
  final VoidCallback? onScanPlate;
  final VoidCallback? onEnterManually;

  static const vehicleWorkStep = 1;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.vehicleIdentificationScreen,
      arguments: claimId,
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
        key: ValueKey(claimId),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.identifyVehicle,
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
                Text(
                  strings.inspectionStepIndicator(
                    vehicleWorkStep,
                    InspectionProgress.totalCount,
                  ),
                  style: context.font14Regular?.copyWith(
                    color: colors.primaryColor,
                    fontWeight: FontWeightHelper.medium,
                    letterSpacing: 0.2,
                  ),
                ),
                context.addVerticalSpace(6),
                const InspectionStepTrack(
                  step: VehicleIdentificationScreen.vehicleWorkStep,
                ),
                context.addVerticalSpace(14),
                Text(
                  strings.identifyVehicleSubtitle,
                  style: context.font16Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
                context.addVerticalSpace(20),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.cardColor,
                      borderRadius: context.circularRadius(20),
                      border: Border.all(color: colors.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: context.circularRadius(20),
                      child: const VehicleScanIllustration(),
                    ),
                  ),
                ),
                context.addVerticalSpace(24),
                AppPrimaryButton(
                  label: strings.scanLicensePlate,
                  prominent: true,
                  icon: Icons.document_scanner_outlined,
                  onPressed:
                      onScanPlate ??
                      () => LicensePlateScannerScreen.open(
                        context,
                        claimId: claimId,
                      ),
                ),
                context.addVerticalSpace(10),
                AppOutlinedButton(
                  label: strings.enterPlateManually,
                  onPressed:
                      onEnterManually ??
                      () => ManualPlateEntryScreen.open(
                        context,
                        claimId: claimId,
                      ),
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
