import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/entities/claim_map_point.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/cubit/accident_location_cubit.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_location_map.dart';

/// Captures where the inspection took place.
///
/// Acquires a real GPS fix on open, shows it on an interactive map with
/// a marker, and reverse geocodes it into an address. Confirming writes
/// `{latitude, longitude, address, capturedAt}` onto the claim through
/// `PUT /claims/{id}/location`, which is the same record the review
/// screen reads back — there is no separate local draft to keep in
/// step.
class AccidentLocationScreen extends StatelessWidget {
  const AccidentLocationScreen({
    super.key,
    required this.claimId,
    this.cubit,
    this.onConfirmed,
  });

  final String claimId;

  /// Injected by tests in place of the real GPS-backed cubit.
  final AccidentLocationCubit? cubit;

  /// Overridden by tests; production continues to the evidence step.
  final VoidCallback? onConfirmed;

  static const mapScreenFraction = 0.46;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    bool replace = false,
  }) {
    if (replace) {
      return context.pushReplacementNamed(
        Routes.accidentLocationScreen,
        arguments: claimId,
      );
    }
    return context.pushNamed(
      Routes.accidentLocationScreen,
      arguments: claimId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccidentLocationCubit>(
      create: (_) =>
          (cubit ??
                AppDependencies.instance.createAccidentLocationCubit(claimId))
            ..locate(),
      child: _AccidentLocationView(onConfirmed: onConfirmed),
    );
  }
}

class _AccidentLocationView extends StatelessWidget {
  const _AccidentLocationView({this.onConfirmed});

  final VoidCallback? onConfirmed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness: context.isDarkTheme
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: BlocConsumer<AccidentLocationCubit, AccidentLocationState>(
        listenWhen: (previous, current) =>
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == AccidentLocationStatus.confirmed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(strings.locationSaved)),
              );
            InspectionProgress.complete(
              state.claimId,
              InspectionStepId.location,
            );
            if (onConfirmed != null) {
              onConfirmed!();
              return;
            }
            VehicleEvidenceScreen.open(context, claimId: state.claimId);
          }
        },
        builder: (context, state) {
          return Scaffold(
            key: ValueKey(state.claimId),
            backgroundColor: colors.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(title: strings.accidentLocation),
                    context.addVerticalSpace(8),
                    Expanded(child: _Body(state: state)),
                    _Actions(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          color: colors.textPrimaryColor,
        ),
        Expanded(
          child: Text(
            title,
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
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final AccidentLocationState state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final location = state.location;

    return LayoutBuilder(
      builder: (context, constraints) {
        final target =
            context.getHeight * AccidentLocationScreen.mapScreenFraction;
        final maxMap = constraints.maxHeight * 0.62;
        final mapHeight = target > maxMap ? maxMap : target;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: mapHeight,
              width: double.infinity,
              child: _MapArea(state: state),
            ),
            context.addVerticalSpace(16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Fact(
                      label: strings.locationAddress,
                      // The resolved address, or an honest note that the
                      // geocoder produced none — never a stand-in.
                      value: location?.address,
                      emptyNote: location == null
                          ? null
                          : strings.addressUnavailable,
                    ),
                    context.addVerticalSpace(14),
                    _Fact(
                      label: strings.coordinatesLabel,
                      value: location?.coordinatesLabel,
                      textDirection: TextDirection.ltr,
                    ),
                    if (location?.accuracy != null) ...[
                      context.addVerticalSpace(14),
                      _Fact(
                        label: strings.locationAccuracy,
                        value: strings.locationAccuracyMetres(
                          location!.accuracy!.round(),
                        ),
                      ),
                    ],
                    if (location != null) ...[
                      context.addVerticalSpace(14),
                      _Fact(
                        label: strings.capturedAtLabel,
                        value: ClaimDateFormatter.capturedAt(
                          strings,
                          location.capturedAt.toLocal(),
                        ),
                      ),
                    ],
                    context.addVerticalSpace(8),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The map, or the state that stands in for it while there is no fix.
class _MapArea extends StatelessWidget {
  const _MapArea({required this.state});

  final AccidentLocationState state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final location = state.location;

    if (location != null) {
      final point = ClaimMapPoint.tryCreate(
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        capturedAt: location.capturedAt,
      );
      if (point != null) {
        return ClaimLocationMap(
          key: const Key('accident-location-map'),
          point: point,
          markerId: 'inspection',
          fillAvailableSpace: true,
        );
      }
    }

    if (state.status == AccidentLocationStatus.locating) {
      return _MapPlaceholder(
        key: const Key('accident-location-loading'),
        icon: Icons.my_location_rounded,
        message: strings.locatingYou,
        showSpinner: true,
      );
    }

    final failure = state.failure;
    return _MapPlaceholder(
      key: const Key('accident-location-error'),
      icon: Icons.location_off_outlined,
      message: failure == null
          ? strings.locationUnavailable
          : _locationMessage(strings, failure),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    super.key,
    required this.icon,
    required this.message,
    this.showSpinner = false,
  });

  final IconData icon;
  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.selectedBackgroundColor,
        borderRadius: context.circularRadius(context.radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Center(
        child: Padding(
          padding: context.spaceHorizontal(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner)
                SizedBox(
                  width: context.width(24),
                  height: context.width(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primaryColor,
                  ),
                )
              else
                Icon(
                  icon,
                  size: context.width(28),
                  color: colors.textSecondaryColor,
                ),
              context.addVerticalSpace(12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.font14Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.state});

  final AccidentLocationState state;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<AccidentLocationCubit>();
    final failure = state.failure;
    // Only the OS can undo a permanent denial, so send them there
    // instead of retrying into the same refusal.
    final needsSettings = failure is LocationPermissionDeniedForeverFailure;

    return Padding(
      padding: context.spaceSymmetric(vertical: 12, horizontal: 0),
      child: Column(
        children: [
          AppPrimaryButton(
            key: const Key('confirm-location'),
            label: strings.confirmLocation,
            prominent: true,
            isLoading: state.status == AccidentLocationStatus.confirming,
            onPressed: state.canConfirm ? cubit.confirm : null,
          ),
          context.addVerticalSpace(10),
          AppOutlinedButton(
            key: const Key('refresh-location'),
            label: needsSettings ? strings.openSettings : strings.refreshLocation,
            onPressed: state.isBusy
                ? null
                : (needsSettings ? cubit.openSettings : cubit.locate),
          ),
        ],
      ),
    );
  }
}

/// Maps a location failure onto copy the adjuster can act on.
String _locationMessage(AppStrings strings, Failure failure) {
  if (failure is LocationServiceDisabledFailure) {
    return strings.locationServicesOff;
  }
  if (failure is LocationPermissionDeniedFailure ||
      failure is LocationPermissionDeniedForeverFailure) {
    return strings.locationPermissionNeeded;
  }
  if (failure is LocationTimeoutFailure) return strings.locationTimedOut;
  return strings.messageFor(failure);
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.emptyNote,
    this.textDirection,
  });

  final String label;

  /// Null when the value has not been captured.
  final String? value;

  /// Shown instead when there is a fix but no value for this field.
  final String? emptyNote;

  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final text = value?.trim();
    final hasValue = text != null && text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font14Regular?.copyWith(
            color: colors.textSecondaryColor,
            fontSize: context.width(12),
          ),
        ),
        context.addVerticalSpace(4),
        Text(
          hasValue ? text : (emptyNote ?? strings.notAvailable),
          textDirection: hasValue ? textDirection : null,
          style: context.font16Bold?.copyWith(
            color: hasValue
                ? colors.textPrimaryColor
                : colors.textSecondaryColor,
            fontWeight: hasValue
                ? FontWeightHelper.semiBold
                : FontWeightHelper.regular,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
