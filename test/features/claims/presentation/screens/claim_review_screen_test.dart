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
      const ClaimReviewScreen(args: ClaimReviewArgs(claimId: 'CLM-0001')),
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
    expect(find.text('Active', skipOffstage: false), findsOneWidget);
    expect(find.text('ACCIDENT', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Rear-end Collision', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Date', skipOffstage: false), findsOneWidget);
    expect(find.text('Time', skipOffstage: false), findsOneWidget);
    expect(find.text('Description', skipOffstage: false), findsOneWidget);
    expect(find.text('LOCATION', skipOffstage: false), findsOneWidget);
    expect(find.text('Captured', skipOffstage: false), findsOneWidget);
    expect(find.text('EVIDENCE', skipOffstage: false), findsOneWidget);
    expect(find.text('7 / 7 photos', skipOffstage: false), findsOneWidget);
    expect(find.text('DOCUMENTS', skipOffstage: false), findsOneWidget);
    expect(find.text('3 / 3 documents', skipOffstage: false), findsOneWidget);
    expect(find.text('SIGNATURE', skipOffstage: false), findsOneWidget);
    expect(find.text('Completed', skipOffstage: false), findsOneWidget);
    expect(find.text('Claim is ready to submit'), findsOneWidget);
    expect(find.byType(ClaimReadyBanner), findsOneWidget);
    expect(
      find.byType(ClaimReviewSectionCard, skipOffstage: false),
      findsNWidgets(8),
    );
    expect(find.text('Edit', skipOffstage: false), findsNWidgets(8));

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
        args: const ClaimReviewArgs(claimId: 'CLM-0001'),
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
  });
}
