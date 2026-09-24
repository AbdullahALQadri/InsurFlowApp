import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/app_router.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_submitted_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_submitted_animation.dart';

void main() {
  Widget wrap(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
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

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size size = const Size(1080, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(child, locale: locale, theme: theme));
    await tester.pump();
  }

  group('success screen', () {
    testWidgets('shows the mark, message and Back to Home', (tester) async {
      await pump(
        tester,
        const ClaimSubmittedScreen(
          args: ClaimSubmittedArgs(claimNumber: 'CLM-DEMO-INS-0011'),
        ),
      );

      expect(find.byType(ClaimSubmittedAnimation), findsOneWidget);
      expect(find.text('Report submitted'), findsOneWidget);
      expect(
        find.text(
          'Your inspection report has been sent to the claims officer '
          'for review.',
        ),
        findsOneWidget,
      );
      expect(find.text('CLM-DEMO-INS-0011'), findsOneWidget);

      final button = tester.widget<AppPrimaryButton>(
        find.byType(AppPrimaryButton),
      );
      expect(button.label, 'Back to Home');
      expect(button.onPressed, isNotNull);
    });

    testWidgets('omits the claim chip when no number was carried through', (
      tester,
    ) async {
      await pump(
        tester,
        const ClaimSubmittedScreen(args: ClaimSubmittedArgs()),
      );

      // The submit response returns only {status}; nothing is invented
      // when the caller had no claim number.
      expect(find.text('Claim'), findsNothing);
      expect(find.text('Report submitted'), findsOneWidget);
    });

    testWidgets('Back to Home triggers the done action', (tester) async {
      var done = false;
      await pump(
        tester,
        ClaimSubmittedScreen(
          args: const ClaimSubmittedArgs(claimNumber: 'CLM-1'),
          onDone: () => done = true,
        ),
      );

      await tester.tap(find.byKey(const Key('back-to-home')));
      await tester.pump();

      expect(done, isTrue);
    });

    testWidgets('system back goes home instead of re-entering the flow', (
      tester,
    ) async {
      var done = false;
      await pump(
        tester,
        ClaimSubmittedScreen(
          args: const ClaimSubmittedArgs(),
          onDone: () => done = true,
        ),
      );

      // Simulates the Android back gesture.
      final widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pump();

      expect(done, isTrue);
    });

    testWidgets('renders in Arabic, right to left', (tester) async {
      await pump(
        tester,
        const ClaimSubmittedScreen(
          args: ClaimSubmittedArgs(claimNumber: 'CLM-1'),
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('تم إرسال التقرير'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('تم إرسال التقرير'))),
        TextDirection.rtl,
      );
    });

    testWidgets('renders under the dark theme', (tester) async {
      await pump(
        tester,
        const ClaimSubmittedScreen(args: ClaimSubmittedArgs()),
        theme: AppTheme.darkTheme,
      );

      expect(find.text('Report submitted'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out on small and large screens', (tester) async {
      for (final size in const [Size(720, 1280), Size(1440, 3200)]) {
        await pump(
          tester,
          const ClaimSubmittedScreen(
            args: ClaimSubmittedArgs(claimNumber: 'CLM-DEMO-INS-0011'),
          ),
          size: size,
        );
        expect(find.byKey(const Key('back-to-home')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('success animation', () {
    testWidgets('runs to completion', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Center(
              child: ClaimSubmittedAnimation(
                size: 120,
                onCompleted: () => completed = true,
              ),
            ),
          ),
        ),
      );

      // The localization delegates resolve asynchronously, so the mark
      // only mounts on the next frame — that is when it starts.
      await tester.pump();
      expect(completed, isFalse);

      await tester.pump(
        ClaimSubmittedAnimation.duration + const Duration(milliseconds: 100),
      );
      await tester.pump();

      expect(completed, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduce-motion shows the final frame immediately', (
      tester,
    ) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: ClaimSubmittedAnimation(
                  size: 120,
                  onCompleted: () => completed = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // No frames were advanced, yet the mark is already complete.
      expect(completed, isTrue);
    });

    testWidgets('disposing mid-animation does not throw', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: Center(child: ClaimSubmittedAnimation(size: 120)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(wrap(const Scaffold(body: SizedBox())));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('navigation', () {
    testWidgets('open() clears the inspection stack above home', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: (settings) {
            if (settings.name == Routes.claimSubmittedScreen) {
              return const AppRouter().generateRoute(settings);
            }
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => ClaimSubmittedScreen.open(
                      context,
                      claimNumber: 'CLM-DEMO-INS-0011',
                    ),
                    child: const Text('home'),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      // Stand in for the inspection screens stacked above home.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('review')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('review'), findsOneWidget);

      navigator.push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const Key('submit'),
                onPressed: () => ClaimSubmittedScreen.open(
                  context,
                  claimNumber: 'CLM-DEMO-INS-0011',
                ),
                child: const Text('validate'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();

      expect(find.byType(ClaimSubmittedScreen), findsOneWidget);
      expect(find.text('CLM-DEMO-INS-0011'), findsOneWidget);

      // Everything between home and the confirmation is gone.
      await tester.tap(find.byKey(const Key('back-to-home')));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(find.text('review'), findsNothing);
      expect(find.text('validate'), findsNothing);
      expect(find.byType(ClaimSubmittedScreen), findsNothing);
    });
  });
}
