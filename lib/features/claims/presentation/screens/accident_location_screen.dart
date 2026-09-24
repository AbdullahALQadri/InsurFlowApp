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
import 'package:insurflow/features/claims/domain/accident_location.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_location_map_card.dart';

class AccidentLocationScreen extends StatelessWidget {
  const AccidentLocationScreen({
    super.key,
    required this.location,
    this.onConfirm,
    this.onRefresh,
  });

  final AccidentLocation location;
  final ValueChanged<AccidentLocation>? onConfirm;
  final VoidCallback? onRefresh;

  static const mapScreenFraction = 0.56;

  static Future<dynamic> open(
    BuildContext context, {
    required AccidentLocation location,
    bool replace = false,
  }) {
    if (replace) {
      return context.pushReplacementNamed(
        Routes.accidentLocationScreen,
        arguments: location,
      );
    }
    return context.pushNamed(
      Routes.accidentLocationScreen,
      arguments: location,
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
        key: ValueKey(location.claimId),
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: colors.textPrimaryColor,
                    ),
                    Expanded(
                      child: Text(
                        strings.accidentLocation,
                        textAlign: TextAlign.center,
                        style: context.font18Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.semiBold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: context.width(48)),
                  ],
                ),
                context.addVerticalSpace(8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final target = context.getHeight * mapScreenFraction;
                      final maxMap = constraints.maxHeight * 0.78;
                      final mapHeight = target > maxMap ? maxMap : target;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: mapHeight,
                            width: double.infinity,
                            child: const AccidentLocationMapCard(),
                          ),
                          context.addVerticalSpace(16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Fact(
                                    label: strings.locationAddress,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location.street.trim().isEmpty
                                              ? strings.notAvailable
                                              : location.street,
                                          style: context.font18Bold?.copyWith(
                                            color: colors.textPrimaryColor,
                                            fontWeight: FontWeightHelper.bold,
                                            height: 1.25,
                                          ),
                                        ),
                                        context.addVerticalSpace(4),
                                        Text(
                                          location.city.trim().isEmpty
                                              ? strings.notAvailable
                                              : location.city,
                                          style: context.font16Regular
                                              ?.copyWith(
                                                color:
                                                    colors.textSecondaryColor,
                                                height: 1.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  context.addVerticalSpace(16),
                                  _Fact(
                                    label: strings.coordinates,
                                    value: location.hasCoordinates
                                        ? location.coordinatesLabel
                                        : strings.notAvailable,
                                  ),
                                  context.addVerticalSpace(16),
                                  _Fact(
                                    label: strings.captured,
                                    value: location.hasCoordinates
                                        ? ClaimDateFormatter.capturedAt(
                                            strings,
                                            location.capturedAt,
                                          )
                                        : strings.notAvailable,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                AppOutlinedButton(
                  label: strings.refreshLocation,
                  onPressed:
                      onRefresh ??
                      () => context.pushReplacementNamed(
                        Routes.capturingLocationScreen,
                        arguments: location.claimId,
                      ),
                ),
                context.addVerticalSpace(10),
                AppPrimaryButton(
                  label: strings.confirmLocation,
                  prominent: true,
                  onPressed: () {
                    if (onConfirm != null) {
                      onConfirm!(location);
                      return;
                    }
                    InspectionProgress.complete(
                      location.claimId,
                      InspectionStepId.location,
                    );
                    VehicleEvidenceScreen.open(
                      context,
                      claimId: location.claimId,
                    );
                  },
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

class _Fact extends StatelessWidget {
  const _Fact({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font14Bold?.copyWith(
            color: colors.textSecondaryColor,
            fontWeight: FontWeightHelper.semiBold,
            height: 1.2,
          ),
        ),
        context.addVerticalSpace(6),
        if (child != null)
          child!
        else
          Text(
            value ?? '',
            style: context.font16Regular?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.medium,
              height: 1.35,
            ),
          ),
      ],
    );
  }
}
