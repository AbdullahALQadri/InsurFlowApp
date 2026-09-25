import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_header_illustration.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_type_grid.dart';

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

  final clock = DateTime(2026, 8, 31, 10, 30);

  testWidgets('shows accident details copy, type grid, and continue', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      AccidentDetailsScreen(
        args: const AccidentDetailsArgs(claimId: 'CLM-0001'),
        clock: clock,
      ),
    );

    expect(find.text('Accident Details'), findsOneWidget);
    expect(find.text('Step 2 of 7'), findsOneWidget);
    expect(find.byType(AccidentHeaderIllustration), findsOneWidget);
    expect(find.byType(AccidentTypeGrid), findsOneWidget);
    expect(find.text('Accident Type'), findsOneWidget);
    // The five values PUT /claims/{id}/accident accepts.
    expect(find.text('Collision'), findsOneWidget);
    expect(find.text('Rear-end Collision'), findsOneWidget);
    expect(find.text('Side Impact'), findsOneWidget);
    expect(find.text('Parking Damage'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Date', skipOffstage: false), findsOneWidget);
    expect(find.text('Time', skipOffstage: false), findsOneWidget);
    expect(find.text('31 Aug 2026', skipOffstage: false), findsOneWidget);
    expect(find.text('10:30 AM', skipOffstage: false), findsOneWidget);
    expect(find.text('Description', skipOffstage: false), findsOneWidget);
    expect(find.text('What happened?', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Damage Description', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Describe the visible damage.', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('shows an almost-there checklist when details are incomplete', (
    tester,
  ) async {
    AccidentDetailsDraft? submitted;

    await pumpScreen(
      tester,
      AccidentDetailsScreen(
        args: const AccidentDetailsArgs(claimId: 'CLM-0001'),
        clock: clock,
        onContinue: (draft) => submitted = draft,
      ),
    );

    await tester.tap(find.byKey(const Key('accident-type-rearEndCollision')));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('accident-damage')),
        matching: find.byType(TextField),
      ),
      'Rear bumper creased with broken lamp.',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Almost there'), findsOneWidget);
    expect(
      find.text('Complete the missing information before continuing.'),
      findsOneWidget,
    );
    expect(find.text('Complete Details'), findsOneWidget);
    expect(find.text('⚠'), findsOneWidget);
    expect(find.text('✓'), findsNWidgets(4));
    expect(submitted, isNull);

    await tester.tap(find.text('Complete Details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Almost there'), findsNothing);
    expect(
      find.text(
        'Add a short description of what happened.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
  });

  testWidgets('continues when the form is complete', (tester) async {
    AccidentDetailsDraft? submitted;

    await pumpScreen(
      tester,
      AccidentDetailsScreen(
        args: const AccidentDetailsArgs(claimId: 'CLM-0001'),
        clock: clock,
        onContinue: (draft) => submitted = draft,
      ),
    );

    await tester.tap(find.byKey(const Key('accident-type-rearEndCollision')));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('accident-description')),
        matching: find.byType(TextField),
      ),
      'The insured vehicle was struck from behind at the junction.',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('accident-damage')),
        matching: find.byType(TextField),
      ),
      'Rear bumper creased with broken lamp.',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(submitted?.type, AccidentType.rearEndCollision);
    expect(submitted?.description, contains('struck from behind'));
    expect(submitted?.damageDescription, contains('Rear bumper'));
  });
}
