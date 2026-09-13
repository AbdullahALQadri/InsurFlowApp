import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_camera_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_camera_overlay.dart';

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

  testWidgets('rear camera shows prompt, guide, capture, gallery, and flash', (
    tester,
  ) async {
    var captured = false;
    var gallery = false;

    await tester.pumpWidget(
      wrap(
        EvidenceCameraScreen(
          args: const EvidenceCameraArgs(
            claimId: 'CLM-0001',
            category: EvidenceCategory.rear,
          ),
          preview: const ColoredBox(color: Color(0xFF05080F)),
          onCapture: () => captured = true,
          onGallery: () => gallery = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Rear'), findsOneWidget);
    expect(
      find.text('Capture the rear of the vehicle clearly.'),
      findsOneWidget,
    );
    expect(
      find.text('Make sure the entire vehicle area is visible.'),
      findsOneWidget,
    );
    expect(find.byType(EvidenceCameraOverlay), findsOneWidget);
    expect(find.byTooltip('Gallery'), findsOneWidget);
    expect(find.byTooltip('Flash'), findsOneWidget);
    expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    expect(find.byKey(const Key('evidence-camera-capture')), findsOneWidget);

    await tester.tap(find.byTooltip('Flash'));
    await tester.pump();
    expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Gallery'));
    await tester.pump();
    expect(gallery, isTrue);

    await tester.tap(find.byKey(const Key('evidence-camera-capture')));
    await tester.pump();
    expect(captured, isTrue);
  });
}
