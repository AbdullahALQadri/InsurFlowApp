import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/capturing_location_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_permission_animation.dart';

class LocationPermissionArgs {
  const LocationPermissionArgs({required this.claimId});

  final String claimId;
}

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({
    super.key,
    required this.args,
    this.onAllow,
    this.onNotNow,
  });

  final LocationPermissionArgs args;
  final VoidCallback? onAllow;
  final VoidCallback? onNotNow;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.locationPermissionScreen,
      arguments: LocationPermissionArgs(claimId: claimId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final lottieSize = context.isSmallScreen
        ? context.height(168)
        : context.height(196);
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
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textPrimaryColor,
                  ),
                ),
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
                              LocationPermissionAnimation(size: lottieSize),
                              context.addVerticalSpace(16),
                              Text(
                                strings.captureAccidentLocation,
                                textAlign: TextAlign.center,
                                style: context.font22Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  height: 1.2,
                                ),
                              ),
                              context.addVerticalSpace(12),
                              Text(
                                strings.captureAccidentLocationSubtitle,
                                textAlign: TextAlign.center,
                                style: context.font16Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                  height: 1.45,
                                ),
                              ),
                              context.addVerticalSpace(24),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.cardColor,
                                  borderRadius: context.circularRadius(16),
                                  border: Border.all(color: colors.borderColor),
                                ),
                                child: Padding(
                                  padding: context.spaceSymmetric(
                                    vertical: 6,
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      _BenefitRow(
                                        label: strings.gpsCoordinates,
                                      ),
                                      Divider(
                                        height: context.height(1),
                                        color: colors.borderColor,
                                      ),
                                      _BenefitRow(
                                        label: strings.locationAddress,
                                      ),
                                      Divider(
                                        height: context.height(1),
                                        color: colors.borderColor,
                                      ),
                                      _BenefitRow(
                                        label: strings.inspectionTimestamp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              context.addVerticalSpace(20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: context.width(16),
                                    color: colors.textSecondaryColor,
                                  ),
                                  context.addHorizontalSpace(8),
                                  Expanded(
                                    child: Text(
                                      strings.locationPrivacyNote,
                                      style: context.font14Regular?.copyWith(
                                        color: colors.textSecondaryColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppPrimaryButton(
                  label: strings.allowLocationAccess,
                  prominent: true,
                  onPressed: () {
                    if (onAllow != null) {
                      onAllow!();
                      return;
                    }
                    CapturingLocationScreen.open(
                      context,
                      claimId: args.claimId,
                      replace: true,
                    );
                  },
                ),
                context.addVerticalSpace(10),
                AppOutlinedButton(
                  label: strings.notNow,
                  onPressed: onNotNow ?? () => context.pop(),
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: context.spaceVertical(12),
      child: Row(
        children: [
          Text(
            '✓',
            style: context.font16Bold?.copyWith(
              color: ClaimStatusColors.approved,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
          context.addHorizontalSpace(12),
          Expanded(
            child: Text(
              label,
              style: context.font16Regular?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
