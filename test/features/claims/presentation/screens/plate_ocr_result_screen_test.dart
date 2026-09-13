import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/screens/plate_ocr_result_screen.dart';
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

  testWidgets('shows detected plate and requires confirmation', (tester) async {
    String? confirmed;
    var retake = false;

    await tester.pumpWidget(
      wrap(
        PlateOcrResultScreen(
          args: const PlateOcrResultArgs(
            claimId: 'CLM-0001',
            plateNumber: 'ABC-1234',
          ),
          onConfirm: (plate) => confirmed = plate,
          onRetake: () => retake = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Plate detected'), findsOneWidget);
    expect(find.text('ABC-1234'), findsWidgets);
    expect(
      find.text('Please verify the detected number before continuing.'),
      findsOneWidget,
    );
    expect(find.byType(StylizedLicensePlate), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(confirmed, 'ABC-1234');

    await tester.tap(find.text('Retake'));
    await tester.pump();
    expect(retake, isTrue);
  });
}
