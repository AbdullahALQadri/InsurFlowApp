import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insurflow/core/error/failures.dart';

/// A GPS fix plus the address it resolves to.
///
/// [address] is null when reverse geocoding produced nothing — the fix
/// is still valid and still usable, so a missing address never blocks
/// capture. Nothing here is invented: the address comes from the
/// platform geocoder or stays null.
@immutable
class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.address,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String? address;

  /// Horizontal accuracy in metres, as reported by the platform.
  final double? accuracy;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  DeviceLocation copyWith({String? address}) => DeviceLocation(
    latitude: latitude,
    longitude: longitude,
    capturedAt: capturedAt,
    address: address ?? this.address,
    accuracy: accuracy,
  );
}

/// Reads the device's position and turns it into an address.
///
/// Wraps `geolocator` and `geocoding` behind a seam so the screens
/// depend on the app's own `Failure` types, and so the capture flow can
/// be tested without a device.
abstract class DeviceLocationService {
  /// Current position, requesting permission first if needed.
  Future<Either<Failure, DeviceLocation>> currentLocation();

  /// Opens the OS settings page for notifications/location, used when
  /// permission was permanently denied.
  Future<void> openLocationSettings();
}

class GeolocatorLocationService implements DeviceLocationService {
  const GeolocatorLocationService();

  @override
  Future<Either<Failure, DeviceLocation>> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Left(LocationServiceDisabledFailure());
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationPermissionDeniedForeverFailure());
      }
      if (permission == LocationPermission.denied) {
        return const Left(LocationPermissionDeniedFailure());
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // A field adjuster is standing at the scene; waiting longer
          // than this suggests the fix is not coming.
          timeLimit: Duration(seconds: 20),
        ),
      );

      final fix = DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        capturedAt: position.timestamp.toUtc(),
        accuracy: position.accuracy,
      );

      return Right(fix.copyWith(address: await _resolveAddress(fix)));
    } on TimeoutException catch (error, stack) {
      // The fix did not arrive in time; the adjuster can retry.
      _log('currentLocation', error, stack);
      return const Left(LocationTimeoutFailure());
    } on Exception catch (error, stack) {
      _log('currentLocation', error, stack);
      return const Left(UnexpectedFailure());
    }
  }

  /// Reverse geocodes a fix into a readable address.
  ///
  /// Returns null on failure rather than throwing: a usable fix without
  /// a street name is still worth keeping, and the coordinates are
  /// shown either way.
  Future<String?> _resolveAddress(DeviceLocation fix) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        fix.latitude,
        fix.longitude,
      );
      if (placemarks.isEmpty) return null;
      return formatPlacemark(placemarks.first);
    } on Exception catch (error, stack) {
      // No geocoder on the device, no network, or nothing found.
      _log('reverseGeocode', error, stack);
      return null;
    }
  }

  /// Joins the parts a placemark actually carries, most specific first,
  /// skipping blanks and duplicates.
  @visibleForTesting
  static String? formatPlacemark(Placemark placemark) {
    final parts = <String>[];
    for (final part in [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ]) {
      final value = part?.trim();
      if (value == null || value.isEmpty) continue;
      if (parts.contains(value)) continue;
      parts.add(value);
    }
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } on Exception catch (error, stack) {
      _log('openLocationSettings', error, stack);
    }
  }

  static void _log(String context, Object error, StackTrace stack) {
    if (kDebugMode) debugPrint('[location] $context failed: $error');
  }
}
