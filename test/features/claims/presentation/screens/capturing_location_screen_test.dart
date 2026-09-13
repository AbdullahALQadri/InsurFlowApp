import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/capturing_location_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_capture_status.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_capturing_animation.dart';

void _ignoreComplete() {}

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

  testWidgets('shows capturing copy, pulse lottie, and live status rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const CapturingLocationScreen(
          args: CapturingLocationArgs(claimId: 'CLM-0001'),
          onComplete: _ignoreComplete,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Getting your location...'), findsOneWidget);
    expect(
      find.text('Searching for the most accurate position.'),
      findsOneWidget,
    );
    expect(find.text('GPS Signal'), findsOneWidget);
    expect(find.text('Searching...'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('Calculating...'), findsOneWidget);
    expect(find.byType(LocationCapturingAnimation), findsOneWidget);
    expect(find.byType(LocationCaptureStatus), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining(RegExp(r'\d+(\.\d+)?\s*(m|km)')), findsNothing);
    expect(find.textContaining(RegExp(r'-?\d+\.\d{2,}')), findsNothing);
  });
}
