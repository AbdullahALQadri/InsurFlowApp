import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/data/models/claim_model.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_detail_sections.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_evidence_gallery.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_timeline_view.dart';

/// Renders the claim detail sections from responses captured verbatim
/// from the live backend, so the UI is checked against the real payload
/// rather than a hand-written stand-in.
Claim _claimFrom(String fixture) {
  final body = jsonDecode(
    File('test/fixtures/api/$fixture.json').readAsStringSync(),
  );
  return ClaimModel.fromResponse(body)!;
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  Future<void> pump(WidgetTester tester, Claim claim) async {
    tester.view.physicalSize = const Size(1080, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(ClaimDetailSections(claim: claim)));
    await tester.pump();
  }

  group('fully captured claim', () {
    testWidgets('renders every populated backend section', (tester) async {
      final claim = _claimFrom('claim_detail_complete');
      await pump(tester, claim);

      const offstage = false;

      // customer {name, phone}
      expect(find.text('CUSTOMER', skipOffstage: offstage), findsOneWidget);
      expect(
        find.text(claim.customerName!, skipOffstage: offstage),
        findsWidgets,
      );
      expect(
        find.text(claim.customerPhone!, skipOffstage: offstage),
        findsOneWidget,
      );

      // vehicle {plateNumber, make, model, year, color}
      expect(find.text('VEHICLE', skipOffstage: offstage), findsOneWidget);
      expect(
        find.text(claim.vehicleMakeModel!, skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text('${claim.vehicle!.year}', skipOffstage: offstage),
        findsOneWidget,
      );

      // accident {...}
      expect(find.text('ACCIDENT', skipOffstage: offstage), findsOneWidget);
      expect(
        find.text(claim.accident!.description!, skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text(claim.accident!.damageDescription!, skipOffstage: offstage),
        findsOneWidget,
      );

      // location {address, coordinates, capturedAt}
      expect(
        find.text('CAPTURED LOCATION', skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text(claim.location!.address!, skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text(claim.location!.coordinatesLabel!, skipOffstage: offstage),
        findsOneWidget,
      );

      // evidence[] and signature
      expect(find.text('EVIDENCE', skipOffstage: offstage), findsOneWidget);
      expect(
        find.byType(ClaimEvidenceGallery, skipOffstage: offstage),
        findsOneWidget,
      );
      expect(find.text('SIGNATURE', skipOffstage: offstage), findsOneWidget);

      // assignment {assignedTo, assignedBy, priority, notes}
      expect(find.text('ASSIGNMENT', skipOffstage: offstage), findsOneWidget);
      expect(
        find.text(claim.assignedTo!.name!, skipOffstage: offstage),
        findsWidgets,
      );
      expect(
        find.text(claim.assignedBy!.name!, skipOffstage: offstage),
        findsWidgets,
      );

      // timeline[]
      expect(find.text('ACTIVITY', skipOffstage: offstage), findsOneWidget);
      expect(
        find.byType(ClaimTimelineView, skipOffstage: offstage),
        findsOneWidget,
      );
    });
  });

  group('claim location map', () {
    // The two captured fixtures are complementary: the submitted claim
    // carries only the adjuster's `location`, the pending one only the
    // reported `incidentCoordinates`. Between them every branch of the
    // location UI is exercised with real backend data.

    testWidgets('maps the adjuster fix when that is what the claim has', (
      tester,
    ) async {
      final claim = _claimFrom('claim_detail_complete');
      expect(claim.incidentCoordinates, isNull, reason: 'fixture guard');
      expect(claim.capturedMapPoint, isNotNull, reason: 'fixture guard');

      await pump(tester, claim);

      final maps = tester
          .widgetList<GoogleMap>(find.byType(GoogleMap, skipOffstage: false))
          .toList();
      expect(maps.length, 1);

      final map = maps.single;
      expect(
        map.initialCameraPosition.target,
        LatLng(
          claim.capturedMapPoint!.latitude,
          claim.capturedMapPoint!.longitude,
        ),
      );
      expect(map.markers.length, 1);
      expect(map.markers.single.position, map.initialCameraPosition.target);
      // The address the backend sent, verbatim.
      expect(
        map.markers.single.infoWindow.snippet,
        claim.location!.address,
      );
    });

    testWidgets('maps the reported position when no fix was captured', (
      tester,
    ) async {
      final claim = _claimFrom('claim_detail_sparse');
      expect(claim.incidentMapPoint, isNotNull, reason: 'fixture guard');
      expect(claim.capturedMapPoint, isNull, reason: 'fixture guard');

      await pump(tester, claim);

      final maps = tester
          .widgetList<GoogleMap>(find.byType(GoogleMap, skipOffstage: false))
          .toList();
      expect(maps.length, 1);
      expect(
        maps.single.initialCameraPosition.target,
        LatLng(
          claim.incidentMapPoint!.latitude,
          claim.incidentMapPoint!.longitude,
        ),
      );

      // The captured-location section states the absence rather than
      // mapping a substituted position.
      expect(
        find.text('Location not captured yet.', skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  group('claim with nothing captured yet', () {
    testWidgets('states what the backend has not recorded', (tester) async {
      final claim = _claimFrom('claim_detail_sparse');
      await pump(tester, claim);

      const offstage = false;

      expect(
        find.text('Accident details not recorded yet.', skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text('Location not captured yet.', skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text('No evidence photos uploaded yet.', skipOffstage: offstage),
        findsOneWidget,
      );
      expect(
        find.text(
          'Customer signature not captured yet.',
          skipOffstage: offstage,
        ),
        findsOneWidget,
      );
      expect(
        find.text('Vehicle details not recorded yet.', skipOffstage: offstage),
        findsOneWidget,
      );

      // The reported plate and assignment are real and still shown.
      expect(
        find.text(claim.plateNumber!, skipOffstage: offstage),
        findsOneWidget,
      );
      // Appears twice, legitimately: once as the assignment note and
      // once on the timeline entry that recorded it.
      expect(
        find.text(claim.assignmentNotes!, skipOffstage: offstage),
        findsWidgets,
      );
    });

    testWidgets('never substitutes a value for a null field', (tester) async {
      final claim = _claimFrom('claim_detail_sparse');
      await pump(tester, claim);

      // No phone on this claim's customer -> the row is absent, not
      // filled with a placeholder.
      expect(find.text('Not available', skipOffstage: false), findsNothing);
      expect(find.text('N/A', skipOffstage: false), findsNothing);
      expect(find.text('null', skipOffstage: false), findsNothing);
      expect(find.text('-', skipOffstage: false), findsNothing);
    });
  });
}
