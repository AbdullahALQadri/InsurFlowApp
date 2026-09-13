import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/license_plate_scanner_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/license_plate_scan_overlay.dart';

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

  testWidgets('scanner shows plate frame copy, flash, and capture', (
    tester,
  ) async {
    var captured = false;

    await tester.pumpWidget(
      wrap(
        LicensePlateScannerScreen(
          claimId: 'CLM-0001',
          preview: const ColoredBox(color: Color(0xFF05080F)),
          onCapture: () => captured = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Scan License Plate'), findsOneWidget);
    expect(
      find.text('Position the license plate inside the frame'),
      findsOneWidget,
    );
    expect(find.text('Keep the plate visible and steady.'), findsOneWidget);
    expect(find.byType(LicensePlateScanOverlay), findsOneWidget);
    expect(find.byTooltip('Flash'), findsOneWidget);
    expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    expect(find.byKey(const Key('license-plate-capture')), findsOneWidget);

    await tester.tap(find.byTooltip('Flash'));
    await tester.pump();
    expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('license-plate-capture')));
    await tester.pump();
    expect(captured, isTrue);
  });
}
