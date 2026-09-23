import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/accident_location.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_location_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_location_map_card.dart';

void main() {
  AccidentLocation locationFixture() {
    return AccidentLocation(
      claimId: 'CLM-0001',
      street: 'Al-Quds Street',
      city: 'Tulkarm',
      latitude: 32.31,
      longitude: 35.03,
      capturedAt: DateTime(2026, 8, 24, 16, 42),
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

  testWidgets('shows map, address, coordinates, captured time, and actions', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      AccidentLocationScreen(location: locationFixture()),
    );

    expect(find.text('Accident Location'), findsOneWidget);
    expect(find.byType(AccidentLocationMapCard), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Accurate'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Al-Quds Street'), findsOneWidget);
    expect(find.text('Tulkarm'), findsOneWidget);
    expect(find.text('Coordinates'), findsOneWidget);
    expect(find.text('32.3100, 35.0300'), findsOneWidget);
    expect(find.text('Captured'), findsOneWidget);
    expect(find.text('24 Aug 2026 · 4:42 PM'), findsOneWidget);
    expect(find.text('Refresh Location'), findsOneWidget);
    expect(find.text('Confirm Location'), findsOneWidget);
    expect(find.text('Live tracking'), findsNothing);
    expect(find.text('Navigation'), findsNothing);
  });

  testWidgets('Confirm Location notifies the host', (tester) async {
    AccidentLocation? confirmed;

    await pumpScreen(
      tester,
      AccidentLocationScreen(
        location: locationFixture(),
        onConfirm: (location) => confirmed = location,
      ),
    );

    await tester.tap(find.text('Confirm Location'));
    await tester.pump();

    expect(confirmed?.coordinatesLabel, '32.3100, 35.0300');
  });

  testWidgets('Refresh Location notifies the host', (tester) async {
    var refreshed = false;

    await pumpScreen(
      tester,
      AccidentLocationScreen(
        location: locationFixture(),
        onRefresh: () => refreshed = true,
      ),
    );

    await tester.tap(find.text('Refresh Location'));
    await tester.pump();

    expect(refreshed, isTrue);
  });
}
