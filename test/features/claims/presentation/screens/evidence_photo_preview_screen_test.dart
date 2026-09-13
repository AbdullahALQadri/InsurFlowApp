import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_photo_preview_screen.dart';

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

  testWidgets('shows rear preview, ready status, and capture actions', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      EvidencePhotoPreviewScreen(
        args: const EvidencePhotoPreviewArgs(
          claimId: 'CLM-0001',
          category: EvidenceCategory.rear,
        ),
        photo: const ColoredBox(color: Color(0xFF12344C)),
      ),
    );

    expect(find.text('Rear'), findsOneWidget);
    expect(find.text('Ready to save'), findsOneWidget);
    expect(find.text('Captured just now'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.text('Use Photo'), findsOneWidget);
    expect(find.text('✓ Rear Photo Added'), findsNothing);
  });

  testWidgets('Use Photo transitions to the saved confirmation', (
    tester,
  ) async {
    var used = false;

    await pumpScreen(
      tester,
      EvidencePhotoPreviewScreen(
        args: const EvidencePhotoPreviewArgs(
          claimId: 'CLM-0001',
          category: EvidenceCategory.rear,
        ),
        photo: const ColoredBox(color: Color(0xFF12344C)),
        onUsePhoto: () => used = true,
      ),
    );

    await tester.tap(find.text('Use Photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));

    expect(used, isTrue);
    expect(find.text('✓ Rear Photo Added'), findsOneWidget);
    expect(find.text('Ready to save'), findsNothing);
    expect(find.text('Retake'), findsNothing);
    expect(find.text('Use Photo'), findsNothing);
    expect(find.text('Rear'), findsOneWidget);
  });

  testWidgets('Retake notifies the host', (tester) async {
    var retake = false;

    await pumpScreen(
      tester,
      EvidencePhotoPreviewScreen(
        args: const EvidencePhotoPreviewArgs(
          claimId: 'CLM-0001',
          category: EvidenceCategory.rear,
        ),
        photo: const ColoredBox(color: Color(0xFF12344C)),
        onRetake: () => retake = true,
      ),
    );

    await tester.tap(find.text('Retake'));
    await tester.pump();
    expect(retake, isTrue);
  });
}
