import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/location_permission_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_permission_animation.dart';

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

  testWidgets('shows location briefing copy, benefits, lottie, and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const LocationPermissionScreen(
          args: LocationPermissionArgs(claimId: 'CLM-0001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Capture Accident Location'), findsOneWidget);
    expect(
      find.text(
        'We use your location to accurately document where the accident was inspected.',
      ),
      findsOneWidget,
    );
    expect(find.text('GPS coordinates'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Inspection timestamp'), findsOneWidget);
    expect(
      find.text(
        'Used only for this claim inspection. Location is not shared outside the file.',
      ),
      findsOneWidget,
    );
    expect(find.text('Allow Location Access'), findsOneWidget);
    expect(find.text('Not Now'), findsOneWidget);
    expect(find.byType(LocationPermissionAnimation), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Allow Location Access notifies the host', (tester) async {
    var allowed = false;

    await tester.pumpWidget(
      wrap(
        LocationPermissionScreen(
          args: const LocationPermissionArgs(claimId: 'CLM-0001'),
          onAllow: () => allowed = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Allow Location Access'));
    await tester.pump();

    expect(allowed, isTrue);
  });

  testWidgets('Not Now notifies the host', (tester) async {
    var skipped = false;

    await tester.pumpWidget(
      wrap(
        LocationPermissionScreen(
          args: const LocationPermissionArgs(claimId: 'CLM-0001'),
          onNotNow: () => skipped = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Not Now'));
    await tester.pump();

    expect(skipped, isTrue);
  });
}
