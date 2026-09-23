import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_lookup_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/stylized_license_plate.dart';

class PlateOcrResultArgs {
  const PlateOcrResultArgs({required this.claimId, required this.plateNumber});

  final String claimId;
  final String plateNumber;
}

class PlateOcrResultScreen extends StatelessWidget {
  const PlateOcrResultScreen({
    super.key,
    required this.args,
    this.onConfirm,
    this.onRetake,
  });

  final PlateOcrResultArgs args;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onRetake;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    required String plateNumber,
  }) {
    return context.pushNamed(
      Routes.plateOcrResultScreen,
      arguments: PlateOcrResultArgs(claimId: claimId, plateNumber: plateNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final plate = args.plateNumber.trim();
    final plateLabel = plate.isEmpty ? strings.notAvailable : plate;
    final lottieSize = context.isSmallScreen
        ? context.height(108)
        : context.height(124);
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
        key: ValueKey(args.claimId),
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppAssetHelper.lottieImage(
                                AppLotties.lottiePlateOcrSuccess,
                                width: lottieSize,
                                height: lottieSize,
                                repeat: false,
                              ),
                              context.addVerticalSpace(8),
                              Text(
                                strings.plateDetected,
                                textAlign: TextAlign.center,
                                style: context.font22Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  height: 1.2,
                                ),
                              ),
                              context.addVerticalSpace(16),
                              Text(
                                plateLabel,
                                textAlign: TextAlign.center,
                                style: context.font34Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  letterSpacing: 2.2,
                                  height: 1.05,
                                  fontSize: context.width(34),
                                ),
                              ),
                              context.addVerticalSpace(16),
                              StylizedLicensePlate(plateNumber: plate),
                              context.addVerticalSpace(16),
                              Text(
                                strings.verifyDetectedPlate,
                                textAlign: TextAlign.center,
                                style: context.font16Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppPrimaryButton(
                  label: strings.confirm,
                  prominent: true,
                  onPressed: plate.isEmpty
                      ? null
                      : () {
                          if (onConfirm != null) {
                            onConfirm!(plate);
                            return;
                          }
                          VehicleLookupScreen.open(
                            context,
                            claimId: args.claimId,
                            plateNumber: plate,
                          );
                        },
                ),
                context.addVerticalSpace(10),
                AppOutlinedButton(
                  label: strings.retake,
                  onPressed: onRetake ?? () => context.pop(),
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
