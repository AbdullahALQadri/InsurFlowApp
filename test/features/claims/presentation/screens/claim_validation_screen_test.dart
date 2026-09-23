import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_validation_animation.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_validation_checks.dart';

void main() {
  ClaimReviewSummary readySummary() {
    return const ClaimReviewSummary(
      claimId: 'CLM-0001',
      claimNumber: 'CLM-0001',
      licensePlate: 'ABC-1234',
      makeModel: 'Toyota Corolla',
      customerName: 'Ahmed Ali',
      policyNumber: 'POL-102938',
      policyStatus: PolicyStatus.active,
      accidentType: AccidentType.rearEnd,
      locationCaptured: true,
      evidenceCompleted: 7,
      evidenceTotal: 7,
      documentsCompleted: 3,
      documentsTotal: 3,
      signatureCompleted: true,
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

  testWidgets('shows checking copy, shield lottie, and no spinner', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimValidationScreen(args: ClaimValidationArgs(summary: readySummary())),
    );

    expect(find.text('Checking your claim'), findsOneWidget);
    expect(
      find.text('We\'re making sure everything required is complete.'),
      findsOneWidget,
    );
    expect(find.byType(ClaimValidationAnimation), findsOneWidget);
    expect(find.byType(ClaimValidationChecks), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Vehicle'), findsNothing);
    expect(find.text('Everything looks good'), findsNothing);

    final continueButton = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(continueButton.label, 'Continue to Submit');
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('reveals the checklist, success line, and continue', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimValidationScreen(
        args: ClaimValidationArgs(summary: readySummary()),
        validationDuration: Duration.zero,
      ),
    );

    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.text('Policy'), findsOneWidget);
    expect(find.text('Accident'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Required Photos'), findsOneWidget);
    expect(find.text('Required Documents'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('Everything looks good'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final continueButton = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('Continue to Submit notifies the host', (tester) async {
    ClaimReviewSummary? submitted;

    await pumpScreen(
      tester,
      ClaimValidationScreen(
        args: ClaimValidationArgs(summary: readySummary()),
        validationDuration: Duration.zero,
        onContinue: (summary) => submitted = summary,
      ),
    );

    await tester.tap(find.text('Continue to Submit'));
    await tester.pump();
    expect(submitted?.claimNumber, 'CLM-0001');
    expect(submitted?.isReady, isTrue);
  });

  testWidgets('Continue to Submit opens the confirmation sheet', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimValidationScreen(
        args: ClaimValidationArgs(summary: readySummary()),
        validationDuration: Duration.zero,
      ),
    );

    await tester.tap(find.text('Continue to Submit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Submit Claim?'), findsOneWidget);
    expect(find.text('CLM-0001'), findsOneWidget);
    expect(find.text('Submit Claim'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
