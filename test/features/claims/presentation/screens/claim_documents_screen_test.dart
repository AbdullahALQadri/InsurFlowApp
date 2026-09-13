import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/app_router.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_documents_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/document_preview_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_document_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/document_illustration.dart';

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
      onGenerateRoute: const AppRouter().generateRoute,
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

  testWidgets('shows document cards, required badges, and disabled continue', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ClaimDocumentsScreen(args: ClaimDocumentsArgs(claimId: 'CLM-0001')),
    );

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Upload the required claim documents.'), findsOneWidget);
    expect(find.text('0 / 3 required documents'), findsOneWidget);
    expect(find.text('Driver License'), findsOneWidget);
    expect(find.text('National ID'), findsOneWidget);
    expect(find.text('Police Report'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Required'), findsNWidgets(3));
    expect(find.text('Optional'), findsOneWidget);
    expect(find.text('Upload'), findsNWidgets(4));
    expect(find.byType(ClaimDocumentCard), findsNWidgets(4));
    expect(find.byType(DocumentIllustration), findsNWidgets(4));

    final continueButton = tester.widget<AppPrimaryButton>(
      find.byType(AppPrimaryButton),
    );
    expect(continueButton.label, 'Continue');
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('upload opens camera, gallery, and files sources', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ClaimDocumentsScreen(args: ClaimDocumentsArgs(claimId: 'CLM-0001')),
    );

    await tester.tap(find.byKey(const Key('document-upload-driverLicense')));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);

    await tester.tap(find.byKey(const Key('document-source-camera')));
    await tester.pumpAndSettle();

    expect(find.text('Review Document'), findsOneWidget);
    expect(find.text('Driver License'), findsWidgets);
    expect(find.text('Ready to save'), findsOneWidget);
    expect(find.text('Captured today'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(DocumentPreviewScreen.savedHold);
    await tester.pumpAndSettle();

    expect(find.text('✓ Uploaded'), findsOneWidget);
    expect(find.text('1 / 3 required documents'), findsOneWidget);
  });

  testWidgets(
    'enables Continue after the three required documents are uploaded',
    (tester) async {
      ClaimDocuments? submitted;
      final uploaded = <ClaimDocumentType>[];

      await pumpScreen(
        tester,
        ClaimDocumentsScreen(
          args: const ClaimDocumentsArgs(claimId: 'CLM-0001'),
          onUpload: (type, source) => uploaded.add(type),
          onContinue: (documents) => submitted = documents,
        ),
      );

      await tester.tap(find.byKey(const Key('document-card-driverLicense')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('document-card-nationalId')));
      await tester.pump();

      expect(find.text('2 / 3 required documents'), findsOneWidget);
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('document-card-policeReport')));
      await tester.pump();

      expect(find.text('3 / 3 required documents'), findsOneWidget);
      expect(find.text('✓ Uploaded'), findsNWidgets(3));
      expect(uploaded, [
        ClaimDocumentType.driverLicense,
        ClaimDocumentType.nationalId,
        ClaimDocumentType.policeReport,
      ]);

      final continueButton = tester.widget<AppPrimaryButton>(
        find.byType(AppPrimaryButton),
      );
      expect(continueButton.onPressed, isNotNull);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(submitted?.canContinue, isTrue);
      expect(submitted?.requiredUploadedCount, 3);
    },
  );

  testWidgets('optional Other does not enable Continue on its own', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ClaimDocumentsScreen(
        args: const ClaimDocumentsArgs(claimId: 'CLM-0001'),
        onUpload: (type, source) {},
      ),
    );

    await tester.tap(find.byKey(const Key('document-card-other')));
    await tester.pump();

    expect(find.text('✓ Uploaded'), findsOneWidget);
    expect(find.text('0 / 3 required documents'), findsOneWidget);
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
      isNull,
    );
  });
}
