import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/customer_signature.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/customer_signature_pad.dart';
import 'package:insurflow/features/claims/presentation/widgets/signature_pen_illustration.dart';

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

  testWidgets('shows confirmation copy, a large canvas, and a disabled confirm', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const CustomerSignatureScreen(
        args: CustomerSignatureArgs(claimId: 'CLM-0001'),
      ),
    );

    expect(find.text('Customer Confirmation'), findsOneWidget);
    expect(
      find.text('Ask the customer to review and sign below.'),
      findsOneWidget,
    );
    expect(find.text('Customer signature'), findsOneWidget);
    expect(
      find.text(
        'By signing, the customer confirms that the collected information and evidence were reviewed.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CustomerSignaturePad), findsOneWidget);
    expect(find.byType(SignaturePenIllustration), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Confirm Signature'), findsOneWidget);

    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<AppOutlinedButton>(find.byType(AppOutlinedButton))
          .onPressed,
      isNull,
    );
  });

  testWidgets('enables Confirm Signature after the customer signs', (
    tester,
  ) async {
    CustomerSignature? confirmed;

    await pumpScreen(
      tester,
      CustomerSignatureScreen(
        args: const CustomerSignatureArgs(claimId: 'CLM-0001'),
        onConfirm: (signature) => confirmed = signature,
      ),
    );

    await tester.drag(
      find.byKey(const Key('signature-canvas')),
      const Offset(120, 40),
    );
    await tester.pump();

    expect(find.text('Customer signature'), findsNothing);
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Confirm Signature'));
    await tester.pump();

    expect(confirmed?.claimId, 'CLM-0001');
    expect(confirmed?.canConfirm, isTrue);
  });

  testWidgets('Clear removes the signature and disables confirm', (
    tester,
  ) async {
    var cleared = false;

    await pumpScreen(
      tester,
      CustomerSignatureScreen(
        args: const CustomerSignatureArgs(claimId: 'CLM-0001'),
        onClear: () => cleared = true,
      ),
    );

    await tester.drag(
      find.byKey(const Key('signature-canvas')),
      const Offset(120, 40),
    );
    await tester.pump();

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(cleared, isTrue);
    expect(find.text('Customer signature'), findsOneWidget);
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).onPressed,
      isNull,
    );
  });
}
