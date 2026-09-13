import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/presentation/screens/document_preview_screen.dart';

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

  testWidgets(
    'shows review title, driver license, ready status, zoom, and actions',
    (tester) async {
      await pumpScreen(
        tester,
        DocumentPreviewScreen(
          args: const DocumentPreviewArgs(
            claimId: 'CLM-0001',
            type: ClaimDocumentType.driverLicense,
            source: DocumentSource.camera,
          ),
          preview: const ColoredBox(color: Color(0xFFE8EEF2)),
        ),
      );

      expect(find.text('Review Document'), findsOneWidget);
      expect(find.text('Driver License'), findsOneWidget);
      expect(find.text('Ready to save'), findsOneWidget);
      expect(find.text('Captured today'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('✓ Driver License saved'), findsNothing);
    },
  );

  testWidgets('Confirm shows the saved verification mark', (tester) async {
    var confirmed = false;

    await pumpScreen(
      tester,
      DocumentPreviewScreen(
        args: const DocumentPreviewArgs(
          claimId: 'CLM-0001',
          type: ClaimDocumentType.driverLicense,
        ),
        preview: const ColoredBox(color: Color(0xFFE8EEF2)),
        onConfirm: () => confirmed = true,
      ),
    );

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));

    expect(confirmed, isTrue);
    expect(find.text('✓ Driver License saved'), findsOneWidget);
    expect(find.text('Ready to save'), findsNothing);
    expect(find.text('Retake'), findsNothing);
    expect(find.text('Confirm'), findsNothing);
    expect(find.text('Review Document'), findsOneWidget);
    expect(find.text('Driver License'), findsOneWidget);
  });

  testWidgets('Retake notifies the host', (tester) async {
    var retake = false;

    await pumpScreen(
      tester,
      DocumentPreviewScreen(
        args: const DocumentPreviewArgs(
          claimId: 'CLM-0001',
          type: ClaimDocumentType.driverLicense,
        ),
        preview: const ColoredBox(color: Color(0xFFE8EEF2)),
        onRetake: () => retake = true,
      ),
    );

    await tester.tap(find.text('Retake'));
    await tester.pump();
    expect(retake, isTrue);
  });
}
