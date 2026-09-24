import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/entities/claim_map_point.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_location_map.dart';

class ClaimLocationMapArgs {
  const ClaimLocationMapArgs({required this.point, required this.markerId});

  final ClaimMapPoint point;
  final String markerId;
}

/// Full-screen view of the same claim coordinates shown on the details
/// card.
///
/// It receives the already-validated [ClaimMapPoint] rather than a claim
/// id, so opening it costs no extra API call and it cannot display a
/// different position from the card it was opened from.
class ClaimLocationMapScreen extends StatelessWidget {
  const ClaimLocationMapScreen({super.key, required this.args});

  final ClaimLocationMapArgs args;

  static Future<dynamic> open(
    BuildContext context, {
    required ClaimMapPoint point,
    required String markerId,
  }) {
    return context.pushNamed(
      Routes.claimLocationMapScreen,
      arguments: ClaimLocationMapArgs(point: point, markerId: markerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final point = args.point;
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
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.claimLocation,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: context.spaceSymmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ClaimLocationMap(
                    point: point,
                    markerId: args.markerId,
                    // Fills whatever space the device gives it rather
                    // than a fixed height.
                    fillAvailableSpace: true,
                    zoom: 16,
                    expandable: false,
                  ),
                ),
              ),
              _LocationFacts(point: point),
            ],
          ),
        ),
      ),
    );
  }
}

/// Only the values the backend attached to this position.
class _LocationFacts extends StatelessWidget {
  const _LocationFacts({required this.point});

  final ClaimMapPoint point;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        border: Border(top: BorderSide(color: colors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: context.spaceSymmetric(vertical: 14, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (point.address != null) ...[
                Text(
                  strings.locationAddress,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    fontSize: context.width(12),
                  ),
                ),
                context.addVerticalSpace(2),
                Text(
                  point.address!,
                  style: context.font16Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                    height: 1.35,
                  ),
                ),
                context.addVerticalSpace(10),
              ],
              Text(
                strings.coordinatesLabel,
                style: context.font14Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  fontSize: context.width(12),
                ),
              ),
              context.addVerticalSpace(2),
              Text(
                point.coordinatesLabel,
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
              if (point.capturedAt != null) ...[
                context.addVerticalSpace(10),
                Text(
                  strings.capturedAtLabel,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    fontSize: context.width(12),
                  ),
                ),
                context.addVerticalSpace(2),
                Text(
                  ClaimDateFormatter.capturedAt(point.capturedAt!),
                  style: context.font16Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
