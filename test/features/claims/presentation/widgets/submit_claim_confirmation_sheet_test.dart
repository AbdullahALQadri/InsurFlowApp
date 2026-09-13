import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/widgets/submit_claim_confirmation_sheet.dart';

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
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows submit copy, claim number, warning, and dominant submit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(const SubmitClaimConfirmationSheet(claimNumber: 'CLM-0001')),
    );
    await tester.pump();

    expect(find.text('Submit Claim?'), findsOneWidget);
    expect(find.text('Claim'), findsOneWidget);
    expect(find.text('CLM-0001'), findsOneWidget);
    expect(
      find.text(
        'After submission, this claim will be sent to the Claims Officer for review.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        "You won't be able to edit the claim unless a correction is requested.",
      ),
      findsOneWidget,
    );

    final submit = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(submit.label, 'Submit Claim');
    expect(submit.prominent, isTrue);
    expect(submit.onPressed, isNotNull);
    expect(find.byType(AppOutlinedButton), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Submit notifies the host', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      wrap(
        SubmitClaimConfirmationSheet(
          claimNumber: 'CLM-0001',
          onSubmit: () => submitted = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Submit Claim'));
    await tester.pump();
    expect(submitted, isTrue);
  });
}
