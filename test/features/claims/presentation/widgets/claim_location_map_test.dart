import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/routing/app_router.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/data/models/claim_model.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/claim_map_point.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_location_map_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_location_map.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_map_style.dart';

/// Coordinates come from responses captured verbatim from the live
/// backend, so the map is exercised with real claim positions.
Claim _claimFrom(String fixture) {
  final body = jsonDecode(
    File('test/fixtures/api/$fixture.json').readAsStringSync(),
  );
  return ClaimModel.fromResponse(body)!;
}

void main() {
  Widget wrap(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size size = const Size(1080, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(child, locale: locale, theme: theme));
    await tester.pump();
  }

  group('ClaimMapPoint accepts only mappable backend coordinates', () {
    test('builds from a real pair', () {
      final point = ClaimMapPoint.tryCreate(
        latitude: 24.648247,
        longitude: 46.711382,
      );

      expect(point, isNotNull);
      expect(point!.latitude, 24.648247);
      expect(point.longitude, 46.711382);
      expect(point.coordinatesLabel, '24.6482, 46.7114');
    });

    test('rejects nulls, NaN, infinity and out-of-range values', () {
      expect(ClaimMapPoint.tryCreate(latitude: null, longitude: 46.7), isNull);
      expect(ClaimMapPoint.tryCreate(latitude: 24.6, longitude: null), isNull);
      expect(ClaimMapPoint.tryCreate(latitude: null, longitude: null), isNull);
      expect(
        ClaimMapPoint.tryCreate(latitude: double.nan, longitude: 46.7),
        isNull,
      );
      expect(
        ClaimMapPoint.tryCreate(
          latitude: 24.6,
          longitude: double.infinity,
        ),
        isNull,
      );
      expect(ClaimMapPoint.tryCreate(latitude: 91, longitude: 46.7), isNull);
      expect(ClaimMapPoint.tryCreate(latitude: -91, longitude: 46.7), isNull);
      expect(ClaimMapPoint.tryCreate(latitude: 24.6, longitude: 181), isNull);
      expect(ClaimMapPoint.tryCreate(latitude: 24.6, longitude: -181), isNull);
    });

    test('never invents an address', () {
      final blank = ClaimMapPoint.tryCreate(
        latitude: 24.6,
        longitude: 46.7,
        address: '   ',
      );
      expect(blank!.address, isNull);

      final real = ClaimMapPoint.tryCreate(
        latitude: 24.6,
        longitude: 46.7,
        address: 'King Fahd Road, Riyadh',
      );
      expect(real!.address, 'King Fahd Road, Riyadh');
    });
  });

  group('Claim exposes the backend positions', () {
    test('reads incidentCoordinates from a real claim payload', () {
      final claim = _claimFrom('claim_detail_sparse');
      final point = claim.incidentMapPoint!;

      expect(point.latitude, claim.incidentCoordinates!.latitude);
      expect(point.longitude, claim.incidentCoordinates!.longitude);
      // incidentLocation is the only address filed with this position.
      expect(point.address, claim.incidentLocation);
      expect(claim.hasMappableLocation, isTrue);
    });

    test('captured location is null until the adjuster records a fix', () {
      final claim = _claimFrom('claim_detail_sparse');

      expect(claim.location, isNull);
      expect(claim.capturedMapPoint, isNull);
      // Falls back to the reported position, not to a stand-in.
      expect(claim.primaryMapPoint, claim.incidentMapPoint);
    });

    test('prefers the adjuster fix once the backend has one', () {
      final claim = _claimFrom('claim_detail_complete');

      expect(claim.capturedMapPoint, isNotNull);
      expect(claim.primaryMapPoint, claim.capturedMapPoint);
      expect(
        claim.capturedMapPoint!.latitude,
        claim.location!.latitude,
      );
      expect(claim.capturedMapPoint!.address, claim.location!.address);
    });
  });

  group('ClaimLocationMap', () {
    testWidgets('centres the camera and marker on the backend position', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_complete').capturedMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'captured'),
      );

      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));

      // Camera sits exactly on the backend coordinates.
      expect(
        map.initialCameraPosition.target,
        LatLng(point.latitude, point.longitude),
      );
      expect(
        map.initialCameraPosition.zoom,
        ClaimLocationMap.defaultZoom,
      );

      // Exactly one marker, at the same position.
      expect(map.markers.length, 1);
      final marker = map.markers.single;
      expect(marker.position, LatLng(point.latitude, point.longitude));
      expect(marker.markerId, const MarkerId('captured'));
      expect(marker.infoWindow.title, 'Claim Location');
      // The real address, not a generated place name.
      expect(marker.infoWindow.snippet, point.address);
    });

    testWidgets('falls back to coordinates when no address was sent', (
      tester,
    ) async {
      final point = ClaimMapPoint.tryCreate(
        latitude: 24.648247,
        longitude: 46.711382,
      )!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
      );

      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.markers.single.infoWindow.snippet, '24.6482, 46.7114');
    });

    testWidgets('lets the user pan, zoom and rotate', (tester) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
      );

      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.scrollGesturesEnabled, isTrue);
      expect(map.zoomGesturesEnabled, isTrue);
      expect(map.rotateGesturesEnabled, isTrue);
      // Lite mode would render a non-interactive bitmap.
      expect(map.liteModeEnabled, isFalse);
    });

    testWidgets('keeps the same platform view across rebuilds', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
      );

      final firstKey = tester.widget<GoogleMap>(find.byType(GoogleMap)).key;

      // Rebuild with an equal point, as a bloc emission would.
      final samePoint = ClaimMapPoint.tryCreate(
        latitude: point.latitude,
        longitude: point.longitude,
        address: point.address,
        capturedAt: point.capturedAt,
      )!;
      await tester.pumpWidget(
        wrap(ClaimLocationMap(point: samePoint, markerId: 'incident')),
      );
      await tester.pump();

      // A stable key means the map is not recreated and the user's own
      // camera position survives; the camera is never driven from here.
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).key,
        firstKey,
      );
    });

    testWidgets('new coordinates move the marker without a teardown', (
      tester,
    ) async {
      // Regression: the map used to be keyed on its coordinates, so a
      // refresh destroyed and rebuilt the platform view, and the
      // replacement could come back on a stale camera — the map showed
      // the wrong place while the address beside it was right.
      final first = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(tester, ClaimLocationMap(point: first, markerId: 'incident'));

      final firstKey = tester.widget<GoogleMap>(find.byType(GoogleMap)).key;

      // A genuinely different position, as a refresh would deliver.
      final moved = ClaimMapPoint.tryCreate(
        latitude: first.latitude + 0.05,
        longitude: first.longitude + 0.05,
        address: first.address,
      )!;
      await tester.pumpWidget(
        wrap(ClaimLocationMap(point: moved, markerId: 'incident')),
      );
      await tester.pump();

      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));

      // One platform view throughout — the camera is animated instead.
      expect(map.key, firstKey);

      // The marker sits on the new coordinates, not the stale ones.
      expect(
        map.markers.single.position,
        LatLng(moved.latitude, moved.longitude),
      );
      expect(
        map.markers.single.position,
        isNot(LatLng(first.latitude, first.longitude)),
      );
    });

    // Separate tests per theme: MaterialApp animates a theme swap, so
    // switching mid-test would read a half-interpolated brightness.
    testWidgets('applies the light map style under the light theme', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
        theme: AppTheme.lightTheme,
      );

      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).style,
        ClaimMapStyle.light,
      );
    });

    testWidgets('applies the dark map style under the dark theme', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
        theme: AppTheme.darkTheme,
      );

      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).style,
        ClaimMapStyle.dark,
      );
    });

    testWidgets('survives a live theme change without losing the map', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
        theme: AppTheme.lightTheme,
      );

      await tester.pumpWidget(
        wrap(
          ClaimLocationMap(point: point, markerId: 'incident'),
          theme: AppTheme.darkTheme,
        ),
      );
      // Not pumpAndSettle: the placeholder spinner runs until the
      // platform fires onMapCreated, which never happens off-device.
      // Pumping past the theme animation is enough.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GoogleMap), findsOneWidget);
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).style,
        ClaimMapStyle.dark,
      );
      // Same coordinates before and after the theme swap.
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap))
            .initialCameraPosition
            .target,
        LatLng(point.latitude, point.longitude),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on small and large screens without overflow', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;

      for (final size in const [
        Size(720, 1280), // compact
        Size(1080, 1920),
        Size(1440, 3200), // large
      ]) {
        await pump(
          tester,
          ClaimLocationMap(point: point, markerId: 'incident'),
          size: size,
        );
        expect(find.byType(GoogleMap), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('full-screen map', () {
    testWidgets('opens with the same coordinates and marker', (tester) async {
      final point = _claimFrom('claim_detail_complete').capturedMapPoint!;

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: const AppRouter().generateRoute,
          home: Scaffold(
            body: ClaimLocationMap(point: point, markerId: 'captured'),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('claim-map-expand')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ClaimLocationMapScreen), findsOneWidget);

      // The card's map is still mounted underneath the pushed route,
      // so scope the lookup to the full-screen one.
      final map = tester.widget<GoogleMap>(
        find.descendant(
          of: find.byType(ClaimLocationMapScreen),
          matching: find.byType(GoogleMap),
        ),
      );
      expect(
        map.initialCameraPosition.target,
        LatLng(point.latitude, point.longitude),
      );
      expect(
        map.markers.single.position,
        LatLng(point.latitude, point.longitude),
      );
      // Interaction stays available in the full-screen view.
      expect(map.scrollGesturesEnabled, isTrue);
      expect(map.zoomGesturesEnabled, isTrue);

      // The real address and coordinates are shown beneath the map.
      expect(find.text(point.address!), findsOneWidget);
      expect(find.text(point.coordinatesLabel), findsOneWidget);

      // A back affordance returns to where it was opened from.
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  group('empty state', () {
    testWidgets('shows localized copy in English and Arabic', (tester) async {
      await pump(tester, const ClaimLocationUnavailable());
      expect(find.text('Location unavailable'), findsOneWidget);
      expect(find.byType(GoogleMap), findsNothing);

      await pump(
        tester,
        const ClaimLocationUnavailable(),
        locale: const Locale('ar'),
      );
      expect(find.text('الموقع غير متوفر'), findsOneWidget);
    });

    testWidgets('renders right-to-left under an Arabic locale', (
      tester,
    ) async {
      final point = _claimFrom('claim_detail_sparse').incidentMapPoint!;
      await pump(
        tester,
        ClaimLocationMap(point: point, markerId: 'incident'),
        locale: const Locale('ar'),
      );

      expect(
        Directionality.of(tester.element(find.byType(GoogleMap))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
