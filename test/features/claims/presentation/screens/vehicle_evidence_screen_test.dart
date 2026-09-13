import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_photo_card.dart';

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

  testWidgets(
    'shows the inspection checklist, required cards, and disabled continue',
    (tester) async {
      await pumpScreen(
        tester,
        const VehicleEvidenceScreen(
          args: VehicleEvidenceArgs(claimId: 'CLM-0001'),
        ),
      );

      expect(find.text('Vehicle Evidence'), findsOneWidget);
      expect(
        find.text('Capture all required photos before submitting.'),
        findsOneWidget,
      );
      expect(find.text('0 / 7 completed'), findsOneWidget);
      expect(find.text('7 required photos remaining.'), findsOneWidget);
      expect(find.text('License Plate'), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Rear'), findsOneWidget);
      expect(find.text('Left Side'), findsOneWidget);
      expect(find.text('Right Side'), findsOneWidget);
      expect(find.text('Damage Close-up'), findsOneWidget);
      expect(find.text('Accident Scene', skipOffstage: false), findsOneWidget);
      expect(find.text('Add Photo'), findsWidgets);
      expect(find.text('Required'), findsWidgets);
      expect(find.byType(EvidencePhotoCard), findsNWidgets(7));

      final continueButton = tester.widget<AppPrimaryButton>(
        find.byType(AppPrimaryButton),
      );
      expect(continueButton.label, 'Continue');
      expect(continueButton.onPressed, isNull);
    },
  );

  testWidgets(
    'shows the completed evidence state when all photos are captured',
    (tester) async {
      VehicleEvidence? submitted;

      await pumpScreen(
        tester,
        VehicleEvidenceScreen(
          args: const VehicleEvidenceArgs(claimId: 'CLM-0001'),
          initial: VehicleEvidence.complete(claimId: 'CLM-0001'),
          onContinue: (evidence) => submitted = evidence,
        ),
      );

      expect(find.byKey(const Key('evidence-complete')), findsOneWidget);
      expect(find.text('7 / 7 Required Photos'), findsOneWidget);
      expect(find.text('Evidence complete'), findsOneWidget);
      expect(
        find.text('All required photos have been captured.'),
        findsOneWidget,
      );
      expect(find.text('License Plate'), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Rear'), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(find.text('Damage Close-up'), findsOneWidget);
      expect(find.text('Accident Scene'), findsOneWidget);
      expect(find.text('Left Side'), findsNothing);
      expect(find.text('Right Side'), findsNothing);
      expect(find.byType(EvidencePhotoCard), findsNothing);
      expect(find.text('Add Photo'), findsNothing);
      expect(find.text('Continue'), findsNothing);

      final continueButton = tester.widget<AppPrimaryButton>(
        find.byType(AppPrimaryButton),
      );
      expect(continueButton.label, 'Continue to Documents');
      expect(continueButton.onPressed, isNotNull);

      await tester.tap(find.text('Continue to Documents'));
      await tester.pump();

      expect(submitted?.canContinue, isTrue);
      expect(submitted?.completedCount, 7);
    },
  );

  testWidgets(
    'reveals the complete state after every required photo is added',
    (tester) async {
      VehicleEvidence? submitted;
      final captured = <EvidenceCategory>[];

      await pumpScreen(
        tester,
        VehicleEvidenceScreen(
          args: const VehicleEvidenceArgs(claimId: 'CLM-0001'),
          onAddPhoto: captured.add,
          onContinue: (evidence) => submitted = evidence,
        ),
      );

      for (final category in EvidenceCategory.values) {
        await tester.ensureVisible(
          find.byKey(Key('evidence-card-${category.name}')),
        );
        await tester.tap(find.byKey(Key('evidence-card-${category.name}')));
        await tester.pump();
      }

      await tester.pump(const Duration(milliseconds: 450));

      expect(captured, EvidenceCategory.values);
      expect(find.byKey(const Key('evidence-complete')), findsOneWidget);
      expect(find.text('7 / 7 Required Photos'), findsOneWidget);
      expect(find.text('Evidence complete'), findsOneWidget);
      expect(
        find.text('All required photos have been captured.'),
        findsOneWidget,
      );
      expect(find.byType(EvidencePhotoCard), findsNothing);

      await tester.tap(find.text('Continue to Documents'));
      await tester.pump();

      expect(submitted?.canContinue, isTrue);
      expect(submitted?.completedCount, 7);
    },
  );
}
