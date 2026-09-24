import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/entities/claim_map_point.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_location_map_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_map_style.dart';

/// Google Map centred on a claim's real backend coordinates.
///
/// [point] is built by the domain layer from the claim payload and is
/// null whenever the backend has no usable coordinates, so this widget
/// is never handed an invalid position. When it is null the caller sees
/// [ClaimLocationUnavailable] instead of a map.
///
/// The camera is set from `initialCameraPosition`, which Google Maps
/// reads only when the platform view is created. Nothing in this widget
/// animates the camera afterwards, so panning and zooming are never
/// interrupted by a rebuild.
class ClaimLocationMap extends StatefulWidget {
  const ClaimLocationMap({
    super.key,
    required this.point,
    required this.markerId,
    this.height,
    this.zoom = defaultZoom,
    this.interactive = true,
    this.expandable = true,
    this.fillAvailableSpace = false,
  });

  /// Street-level without implying more precision than a single fix has.
  static const double defaultZoom = 15;

  final ClaimMapPoint point;

  /// Distinguishes the reported and captured markers when both appear
  /// on one screen.
  final String markerId;

  final double? height;
  final double zoom;

  /// Panning and zooming inside the card. The full-screen view always
  /// allows both.
  final bool interactive;

  /// Tapping opens [ClaimLocationMapScreen] with the same coordinates.
  final bool expandable;

  /// Fills the parent instead of using [height]. Used by the
  /// full-screen view so the map adapts to any device size.
  final bool fillAvailableSpace;

  @override
  State<ClaimLocationMap> createState() => _ClaimLocationMapState();
}

class _ClaimLocationMapState extends State<ClaimLocationMap> {
  /// Tracks only whether the first frame of the map has been handed
  /// over, so the placeholder can be removed. No controller is retained:
  /// nothing here ever drives the camera, which is what guarantees the
  /// user's pan and zoom are never reset. `GoogleMap` disposes its own
  /// controller.
  var _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final brightness = Theme.of(context).brightness;
    final radius = context.circularRadius(14);
    final point = widget.point;

    final map = GoogleMap(
      // Rebuilding with a new key for new coordinates is what moves the
      // camera to another claim; within one claim the platform view is
      // kept, so the user's own pan and zoom survive every rebuild.
      key: ValueKey('claim-map-${widget.markerId}-${point.mapKey}'),
      initialCameraPosition: CameraPosition(
        target: LatLng(point.latitude, point.longitude),
        zoom: widget.zoom,
      ),
      style: ClaimMapStyle.of(brightness),
      markers: {
        Marker(
          markerId: MarkerId(widget.markerId),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(
            title: strings.claimLocation,
            // Only ever the address the backend sent; when it sent
            // none, the coordinates themselves are shown rather than an
            // invented place name.
            snippet: point.address ?? point.coordinatesLabel,
          ),
        ),
      },
      onMapCreated: (_) {
        if (!mounted) return;
        setState(() => _isMapReady = true);
      },
      zoomGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: widget.interactive,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      liteModeEnabled: false,
    );

    // A design-height value on the card; the parent's full height in
    // the full-screen view.
    final resolvedHeight = widget.fillAvailableSpace
        ? double.infinity
        : context.height(widget.height ?? 160);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: double.infinity,
        height: resolvedHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.selectedBackgroundColor,
            borderRadius: radius,
            border: Border.all(color: colors.borderColor),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              map,
              // Covers the brief gap before the first tiles paint so the
              // card never flashes an empty platform view.
              if (!_isMapReady)
                ColoredBox(
                  color: colors.selectedBackgroundColor,
                  child: Center(
                    child: SizedBox(
                      width: context.width(22),
                      height: context.width(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primaryColor,
                      ),
                    ),
                  ),
                ),
              // Always available once there are coordinates: the
              // affordance must not depend on tiles having loaded.
              if (widget.expandable)
                PositionedDirectional(
                  top: context.height(10),
                  end: context.width(10),
                  child: _ExpandButton(point: point, markerId: widget.markerId),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.point, required this.markerId});

  final ClaimMapPoint point;
  final String markerId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final radius = context.circularRadius(100);

    return Material(
      color: colors.cardColor.changeOpacity(0.94),
      borderRadius: radius,
      child: InkWell(
        key: const Key('claim-map-expand'),
        borderRadius: radius,
        onTap: () => ClaimLocationMapScreen.open(
          context,
          point: point,
          markerId: markerId,
        ),
        child: Padding(
          padding: context.spaceSymmetric(vertical: 6, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_full_rounded,
                size: context.width(13),
                color: colors.primaryColor,
              ),
              context.addHorizontalSpace(6),
              Text(
                strings.viewLargerMap,
                style: context.font14Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  fontSize: context.width(11),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown in place of the map when the backend returned no usable
/// coordinates. States the fact rather than centring the map on a
/// stand-in position.
class ClaimLocationUnavailable extends StatelessWidget {
  const ClaimLocationUnavailable({super.key, this.height, this.message});

  final double? height;

  /// Defaults to the generic "Location unavailable"; sections with a
  /// more specific reason pass their own copy.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final radius = context.circularRadius(14);

    return Container(
      key: const Key('claim-map-unavailable'),
      width: double.infinity,
      height: context.height(height ?? 96),
      decoration: BoxDecoration(
        color: colors.selectedBackgroundColor,
        borderRadius: radius,
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: context.width(22),
            color: colors.textSecondaryColor,
          ),
          context.addVerticalSpace(6),
          Padding(
            padding: context.spaceHorizontal(16),
            child: Text(
              message ?? strings.locationUnavailable,
              textAlign: TextAlign.center,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
                height: 1.35,
                fontSize: context.width(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
