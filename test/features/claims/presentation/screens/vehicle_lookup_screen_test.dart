import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_lookup_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_lookup_animation.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_lookup_checks.dart';

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

  testWidgets('shows finding-vehicle copy, plate, lottie, and lookup checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const VehicleLookupScreen(
          args: VehicleLookupArgs(claimId: 'CLM-0001', plateNumber: 'ABC-1234'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Finding vehicle'), findsOneWidget);
    expect(find.text('ABC-1234'), findsOneWidget);
    expect(
      find.text('Checking vehicle and policy information...'),
      findsOneWidget,
    );
    expect(find.byType(VehicleLookupAnimation), findsOneWidget);
    expect(find.byType(VehicleLookupChecks), findsOneWidget);
    expect(find.text('Vehicle information'), findsOneWidget);
    expect(find.text('Customer information'), findsOneWidget);
    expect(find.text('Policy information'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('notifies when the staged lookup finishes', (tester) async {
    var complete = false;

    await tester.pumpWidget(
      wrap(
        VehicleLookupScreen(
          args: const VehicleLookupArgs(
            claimId: 'CLM-0001',
            plateNumber: 'ABC-1234',
          ),
          lookupDuration: const Duration(milliseconds: 80),
          onComplete: () => complete = true,
        ),
      ),
    );
    await tester.pump();
    expect(complete, isFalse);

    await tester.pump(const Duration(milliseconds: 90));
    expect(complete, isTrue);
    expect(find.text('Vehicle information'), findsOneWidget);
    expect(find.text('Policy information'), findsOneWidget);
  });
}
