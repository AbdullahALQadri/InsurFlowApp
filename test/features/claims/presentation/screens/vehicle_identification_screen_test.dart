import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_scan_illustration.dart';

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

  testWidgets('shows identify-vehicle copy, scan card, and both actions', (
    tester,
  ) async {
    var scanned = false;
    var manual = false;

    await tester.pumpWidget(
      wrap(
        VehicleIdentificationScreen(
          claimId: 'CLM-0001',
          onScanPlate: () => scanned = true,
          onEnterManually: () => manual = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Vehicle Identification'), findsOneWidget);
    expect(
      find.text('Confirm the vehicle assigned to this claim.'),
      findsOneWidget,
    );
    expect(find.text('Step 1 of 7'), findsOneWidget);
    expect(find.byType(VehicleScanIllustration), findsOneWidget);
    expect(find.text('Scan License Plate'), findsOneWidget);
    expect(find.text('Enter Plate Manually'), findsOneWidget);

    await tester.tap(find.text('Scan License Plate'));
    await tester.pump();
    expect(scanned, isTrue);

    await tester.tap(find.text('Enter Plate Manually'));
    await tester.pump();
    expect(manual, isTrue);
  });
}
