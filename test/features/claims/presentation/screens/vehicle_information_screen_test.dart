import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_information_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/policy_active_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/stylized_license_plate.dart';
import 'package:insurflow/features/claims/presentation/widgets/verified_lookup_card.dart';

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

  testWidgets('shows verified vehicle, customer, and policy cards', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      VehicleInformationScreen(
        result: VehicleLookupResult.demo(claimId: 'CLM-0001'),
      ),
    );

    expect(find.text('Vehicle Information'), findsOneWidget);
    expect(find.text('VEHICLE'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    expect(find.text('White'), findsOneWidget);
    expect(find.text('License Plate'), findsOneWidget);
    expect(find.text('ABC-1234'), findsWidgets);
    expect(find.byType(StylizedLicensePlate), findsOneWidget);

    expect(find.text('CUSTOMER'), findsOneWidget);
    expect(find.text('Ahmed Ali'), findsOneWidget);
    expect(find.text('059xxxxxxx'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('POL-102938'), 80);
    await tester.pump();

    expect(find.text('POLICY'), findsOneWidget);
    expect(find.text('POL-102938'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('01 Jan 2026 — 31 Dec 2026'), findsOneWidget);
    expect(find.byType(PolicyActiveBadge), findsOneWidget);
    expect(find.byType(VerifiedLookupCard), findsNWidgets(3));

    expect(find.text('Confirm Information'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('confirm and edit invoke the provided callbacks', (tester) async {
    VehicleLookupResult? confirmed;
    var edited = false;

    await pumpScreen(
      tester,
      VehicleInformationScreen(
        result: VehicleLookupResult.demo(claimId: 'CLM-0001'),
        onConfirm: (result) => confirmed = result,
        onEdit: () => edited = true,
      ),
    );

    await tester.tap(find.text('Confirm Information'));
    await tester.pump();
    expect(confirmed?.policyNumber, 'POL-102938');
    expect(confirmed?.licensePlate, 'ABC-1234');

    await tester.tap(find.text('Edit'));
    await tester.pump();
    expect(edited, isTrue);
  });
}
