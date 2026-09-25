import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_review_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_ready_banner.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_review_section_card.dart';

void main() {
  /// Mirrors a fully captured claim as `GET /claims/{id}` returns it.
  /// Passing a snapshot keeps the widget test off the network; the
  /// screen's own loading path is covered by the model tests.
  ClaimReviewSummary readySummary() {
    return const ClaimReviewSummary(
      claimId: '6a91ab09c9ff1dc54fabf15b',
      claimNumber: 'CLM-0001',
      licensePlate: 'ABC-1234',
      makeModel: 'Toyota Corolla',
      customerName: 'Ahmed Ali',
      policyNumber: 'POL-102938',
      policyStatus: 'ACTIVE',
      accidentType: 'REAR_END_COLLISION',
      accidentDate: '2026-08-28',
      accidentTime: '14:30',
      accidentDescription: 'Hit from behind at a red light.',
      locationAddress: 'King Fahd Road, Riyadh',
      locationCoordinates: '24.7136, 46.6753',
      evidenceCount: 1,
      signatureCaptured: true,
      vehicleLinked: true,
    );
  }

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
      home: child,
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(child));
    await tester.pump();
  }

  testWidgets('shows claim number, section cards, readiness, and submit', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimReviewScreen(
        args: ClaimReviewArgs(
          claimId: '6a91ab09c9ff1dc54fabf15b',
          summary: readySummary(),
        ),
      ),
    );

    expect(find.text('Review Claim'), findsOneWidget);
    expect(find.text('Claim'), findsOneWidget);
    expect(find.text('CLM-0001'), findsOneWidget);
    expect(find.text('VEHICLE', skipOffstage: false), findsOneWidget);
    expect(find.text('ABC-1234', skipOffstage: false), findsOneWidget);
    expect(find.text('Toyota Corolla', skipOffstage: false), findsOneWidget);
    expect(find.text('CUSTOMER', skipOffstage: false), findsOneWidget);
    expect(find.text('Ahmed Ali', skipOffstage: false), findsOneWidget);
    expect(find.text('POLICY', skipOffstage: false), findsOneWidget);
    expect(find.text('POL-102938', skipOffstage: false), findsOneWidget);
    expect(find.text('ACTIVE', skipOffstage: false), findsOneWidget);
    expect(find.text('ACCIDENT', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Rear-end Collision', skipOffstage: false),
      findsOneWidget,
    );
    // Real accident values, not the field names.
    expect(find.text('28 Aug 2026', skipOffstage: false), findsOneWidget);
    expect(find.text('14:30', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Hit from behind at a red light.', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('LOCATION', skipOffstage: false), findsOneWidget);
    expect(
      find.text('King Fahd Road, Riyadh', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('24.7136, 46.6753', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('EVIDENCE', skipOffstage: false), findsOneWidget);
    expect(find.text('1 photo', skipOffstage: false), findsOneWidget);
    expect(find.text('SIGNATURE', skipOffstage: false), findsOneWidget);
    expect(find.text('Captured', skipOffstage: false), findsOneWidget);
    expect(find.text('Claim is ready to submit'), findsOneWidget);
    expect(find.byType(ClaimReadyBanner), findsOneWidget);
    expect(
      find.byType(ClaimReviewSectionCard, skipOffstage: false),
      findsNWidgets(7),
    );
    expect(find.text('Edit', skipOffstage: false), findsNWidgets(7));

    final submit = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(submit.label, 'Submit Claim');
    expect(submit.onPressed, isNotNull);
  });

  testWidgets('Edit and Submit notify the host', (tester) async {
    ClaimReviewSectionId? edited;
    ClaimReviewSummary? submitted;

    await pumpScreen(
      tester,
      ClaimReviewScreen(
        args: ClaimReviewArgs(
          claimId: '6a91ab09c9ff1dc54fabf15b',
          summary: readySummary(),
        ),
        onEdit: (section) => edited = section,
        onSubmit: (summary) => submitted = summary,
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('review-edit-vehicle')));
    await tester.tap(find.byKey(const Key('review-edit-vehicle')));
    await tester.pump();
    expect(edited, ClaimReviewSectionId.vehicle);

    await tester.tap(find.text('Submit Claim'));
    await tester.pump();
    expect(submitted?.isReady, isTrue);
    expect(submitted?.claimNumber, 'CLM-0001');
    expect(submitted?.makeModel, 'Toyota Corolla');
  });

  testWidgets('an incomplete claim names what the backend still needs', (
    tester,
  ) async {
    // `POST /claims/{id}/inspection/submit` answers "Inspection
    // incomplete. Missing: accident, signature" for this claim, so the
    // screen says the same before the request is spent.
    await pumpScreen(
      tester,
      ClaimReviewScreen(
        args: ClaimReviewArgs(
          claimId: '6a91ab09c9ff1dc54fabf15b',
          summary: const ClaimReviewSummary(
            claimId: '6a91ab09c9ff1dc54fabf15b',
            claimNumber: 'CLM-0001',
            licensePlate: 'ABC-1234',
            makeModel: 'Toyota Corolla',
            locationAddress: 'King Fahd Road, Riyadh',
            evidenceCount: 2,
            vehicleLinked: true,
          ),
        ),
      ),
    );

    expect(find.byType(ClaimReadyBanner), findsNothing);
    expect(find.byKey(const Key('review-missing-banner')), findsOneWidget);
    expect(find.text('This claim is not ready yet'), findsOneWidget);
    expect(
      find.text('Still needed: Accident and Signature'),
      findsOneWidget,
    );

    // Submitting is blocked, because the backend would reject it.
    final submit = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(submit.onPressed, isNull);
  });

  testWidgets('a single missing section reads without a conjunction', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimReviewScreen(
        args: ClaimReviewArgs(
          claimId: '6a91ab09c9ff1dc54fabf15b',
          summary: ClaimReviewSummary(
            claimId: readySummary().claimId,
            claimNumber: readySummary().claimNumber,
            licensePlate: readySummary().licensePlate,
            accidentType: readySummary().accidentType,
            locationAddress: readySummary().locationAddress,
            evidenceCount: 1,
            vehicleLinked: true,
          ),
        ),
      ),
    );

    expect(find.text('Still needed: Signature'), findsOneWidget);
  });

  testWidgets('the sections read from the claim, never from placeholders', (
    tester,
  ) async {
    // A claim where the backend holds nothing yet: every section says
    // so explicitly rather than showing an invented value.
    await pumpScreen(
      tester,
      ClaimReviewScreen(
        args: const ClaimReviewArgs(
          claimId: '6a91ab09c9ff1dc54fabf15b',
          summary: ClaimReviewSummary(
            claimId: '6a91ab09c9ff1dc54fabf15b',
            claimNumber: 'CLM-0001',
          ),
        ),
      ),
    );

    expect(
      find.text('Accident details not recorded yet.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Location not captured yet.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('No evidence photos uploaded yet.', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Customer signature not captured yet.', skipOffstage: false),
      findsOneWidget,
    );
    // Nothing was uploaded, so no media frames are drawn at all.
    expect(
      find.byKey(const Key('review-evidence-thumbnails')),
      findsNothing,
    );
    expect(find.byKey(const Key('review-signature-preview')), findsNothing);
  });
}
