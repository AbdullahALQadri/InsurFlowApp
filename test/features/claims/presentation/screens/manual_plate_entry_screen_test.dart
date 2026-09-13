import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/manual_plate_entry_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/stylized_license_plate.dart';

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

  testWidgets('shows focused manual plate entry copy and plate visual', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ManualPlateEntryScreen(
          args: ManualPlateEntryArgs(claimId: 'CLM-0001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Enter License Plate'), findsOneWidget);
    expect(
      find.text('Type the plate number exactly as shown on the vehicle.'),
      findsOneWidget,
    );
    expect(find.text('ABC-1234'), findsWidgets);
    expect(find.byType(StylizedLicensePlate), findsOneWidget);
    expect(find.text('Confirm Plate'), findsOneWidget);
    expect(find.text('Valid format ✓'), findsNothing);
    expect(find.text('Please enter a valid license plate.'), findsNothing);
  });

  testWidgets('shows valid format when the plate matches ABC-1234', (
    tester,
  ) async {
    String? confirmed;

    await tester.pumpWidget(
      wrap(
        ManualPlateEntryScreen(
          args: const ManualPlateEntryArgs(claimId: 'CLM-0001'),
          onConfirm: (plate) => confirmed = plate,
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('manual-plate-input')),
      'abc1234',
    );
    await tester.pump();

    expect(find.text('ABC-1234'), findsWidgets);
    expect(find.text('Valid format ✓'), findsOneWidget);

    await tester.tap(find.text('Confirm Plate'));
    await tester.pump();
    expect(confirmed, 'ABC-1234');
  });

  testWidgets('shows an error when confirm is tapped with an invalid plate', (
    tester,
  ) async {
    var confirmed = false;

    await tester.pumpWidget(
      wrap(
        ManualPlateEntryScreen(
          args: const ManualPlateEntryArgs(claimId: 'CLM-0001'),
          onConfirm: (_) => confirmed = true,
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const Key('manual-plate-input')), 'AB');
    await tester.tap(find.text('Confirm Plate'));
    await tester.pump();

    expect(find.text('Please enter a valid license plate.'), findsOneWidget);
    expect(find.text('Valid format ✓'), findsNothing);
    expect(confirmed, isFalse);
  });
}
