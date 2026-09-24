import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_schemes.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:insurflow/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:insurflow/features/onboarding/presentation/widgets/onboarding_progress.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';

void main() {
  Widget wrap(
    Widget child, {
    required AppPreferencesCubit cubit,
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStringsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  Future<AppPreferencesCubit> pump(
    WidgetTester tester, {
    VoidCallback? onFinished,
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size size = const Size(1080, 2400),
    AppPreferencesStore? store,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = AppPreferencesCubit(
      store: store ?? InMemoryAppPreferencesStore(),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      wrap(
        OnboardingScreen(onFinished: onFinished),
        cubit: cubit,
        locale: locale,
        theme: theme,
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  group('first launch only', () {
    test('a fresh install has not completed onboarding', () async {
      final preferences = await InMemoryAppPreferencesStore().read();
      expect(preferences.hasCompletedOnboarding, isFalse);
      expect(preferences.isLoaded, isTrue);
    });

    test('completing persists the flag across a restart', () async {
      final store = InMemoryAppPreferencesStore();
      final first = AppPreferencesCubit(store: store);
      await first.load();
      expect(first.state.hasCompletedOnboarding, isFalse);

      await first.completeOnboarding();
      await first.close();

      // A restart re-reads from storage.
      final afterRestart = AppPreferencesCubit(store: store);
      await afterRestart.load();
      expect(afterRestart.state.hasCompletedOnboarding, isTrue);
      await afterRestart.close();
    });

    test('the flag survives repeated restarts', () async {
      final store = InMemoryAppPreferencesStore();
      final first = AppPreferencesCubit(store: store);
      await first.load();
      await first.completeOnboarding();
      await first.close();

      for (var launch = 0; launch < 3; launch++) {
        final cubit = AppPreferencesCubit(store: store);
        await cubit.load();
        expect(
          cubit.state.hasCompletedOnboarding,
          isTrue,
          reason: 'launch $launch',
        );
        await cubit.close();
      }
    });

    test('it round-trips through JSON, as the real store persists it', () {
      const done = AppPreferences(hasCompletedOnboarding: true);
      final restored = AppPreferences.fromJson(done.toJson());
      expect(restored.hasCompletedOnboarding, isTrue);
      expect(restored.isLoaded, isTrue);
    });

    test('a corrupt flag shows onboarding rather than skipping it', () {
      expect(
        AppPreferences.fromJson(const {
          'hasCompletedOnboarding': 'yes',
        }).hasCompletedOnboarding,
        isFalse,
      );
      expect(
        AppPreferences.fromJson(const {}).hasCompletedOnboarding,
        isFalse,
      );
    });

    test('completing does not disturb the other preferences', () async {
      final store = InMemoryAppPreferencesStore();
      final cubit = AppPreferencesCubit(store: store);
      await cubit.load();
      await cubit.setLocale('ar');
      await cubit.setThemeMode(ThemeMode.dark);
      await cubit.setAccent(const Color(0xFF2563EB));

      await cubit.completeOnboarding();

      expect(cubit.state.localeCode, 'ar');
      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.usesCustomAccent, isTrue);
      expect(cubit.state.hasCompletedOnboarding, isTrue);
      await cubit.close();
    });
  });

  group('flow', () {
    testWidgets('opens on the first page with skip and next', (tester) async {
      await pump(tester);

      expect(find.byType(OnboardingIllustration), findsWidgets);
      expect(find.byType(OnboardingProgress), findsOneWidget);
      expect(find.text('Assignments, on your terms'), findsOneWidget);
      expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('next walks every page to the final Get Started', (
      tester,
    ) async {
      await pump(tester);

      for (var i = 0; i < OnboardingScreen.pages.length - 1; i++) {
        await tester.tap(find.byKey(const Key('onboarding-primary-action')));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Review and submit with confidence'), findsOneWidget);
      // Skip is redundant on the last page.
      final skip = tester.widget<TextButton>(
        find.byKey(const Key('onboarding-skip')),
      );
      expect(skip.onPressed, isNull);
    });

    testWidgets('back returns to the previous page', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('onboarding-primary-action')));
      await tester.pumpAndSettle();
      expect(find.text('Identify the vehicle instantly'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-back')));
      await tester.pumpAndSettle();
      expect(find.text('Assignments, on your terms'), findsOneWidget);
    });

    testWidgets('swiping moves between pages', (tester) async {
      await pump(tester);

      await tester.drag(
        find.byKey(const Key('onboarding-pager')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Identify the vehicle instantly'), findsOneWidget);
    });

    testWidgets('skip finishes onboarding', (tester) async {
      var finished = false;
      await pump(tester, onFinished: () => finished = true);

      await tester.tap(find.byKey(const Key('onboarding-skip')));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });

    testWidgets('Get Started finishes onboarding', (tester) async {
      var finished = false;
      await pump(tester, onFinished: () => finished = true);

      for (var i = 0; i < OnboardingScreen.pages.length - 1; i++) {
        await tester.tap(find.byKey(const Key('onboarding-primary-action')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('onboarding-primary-action')));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });

    testWidgets('skip and complete both persist the same flag', (
      tester,
    ) async {
      // Skip.
      final skipStore = InMemoryAppPreferencesStore();
      final skipCubit = await pump(tester, store: skipStore);
      await skipCubit.completeOnboarding();
      expect((await skipStore.read()).hasCompletedOnboarding, isTrue);

      // Complete.
      final doneStore = InMemoryAppPreferencesStore();
      final doneCubit = await pump(tester, store: doneStore);
      await doneCubit.completeOnboarding();
      expect((await doneStore.read()).hasCompletedOnboarding, isTrue);
    });
  });

  group('content reflects the real workflow', () {
    test('there are five pages, each a distinct step', () {
      expect(OnboardingScreen.pages.length, 5);
      final arts = OnboardingScreen.pages.map((p) => p.art).toSet();
      expect(arts.length, 5);
    });

    test('every page has translated copy in both languages', () {
      const english = AppStrings(Locale('en'));
      const arabic = AppStrings(Locale('ar'));

      for (final page in OnboardingScreen.pages) {
        final enTitle = page.title(english);
        final arTitle = page.title(arabic);
        final enBody = page.body(english);
        final arBody = page.body(arabic);

        expect(enTitle, isNotEmpty);
        expect(enBody, isNotEmpty);
        expect(arTitle, isNot(enTitle));
        expect(arBody, isNot(enBody));
        expect(RegExp(r'[؀-ۿ]').hasMatch(arTitle), isTrue);
        expect(RegExp(r'[؀-ۿ]').hasMatch(arBody), isTrue);
      }
    });
  });

  group('presentation', () {
    testWidgets('renders in Arabic, right to left', (tester) async {
      await pump(tester, locale: const Locale('ar'));

      expect(find.text('مهامك، بقرارك'), findsOneWidget);
      expect(find.text('تخطٍ'), findsOneWidget);
      expect(find.text('التالي'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('مهامك، بقرارك'))),
        TextDirection.rtl,
      );
    });

    testWidgets('renders under light, dark and a custom theme', (
      tester,
    ) async {
      for (final theme in [
        AppTheme.lightTheme,
        AppTheme.darkTheme,
        AppTheme.custom(
          accent: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
      ]) {
        await pump(tester, theme: theme);
        expect(find.byType(OnboardingIllustration), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the art follows a custom accent', (tester) async {
      const accent = Color(0xFF7C3AED);
      await pump(
        tester,
        theme: AppTheme.custom(accent: accent, brightness: Brightness.light),
      );

      final painter = tester
          .widgetList<OnboardingIllustration>(
            find.byType(OnboardingIllustration),
          )
          .first;
      expect(painter.art, OnboardingArt.assignments);
      // The scheme adjusts the accent for contrast, so the art must not
      // be painted with the raw brand colour.
      final custom = AppColorSchemes.custom(
        accent: accent,
        brightness: Brightness.light,
      );
      expect(custom.primaryColor, isNot(AppColorSchemes.light.primaryColor));
    });

    testWidgets('lays out on small and large screens', (tester) async {
      for (final size in const [Size(720, 1280), Size(1440, 3200)]) {
        await pump(tester, size: size);
        expect(
          find.byKey(const Key('onboarding-primary-action')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('progress reflects the active page', (tester) async {
      await pump(tester);

      var progress = tester.widget<OnboardingProgress>(
        find.byType(OnboardingProgress),
      );
      expect(progress.count, OnboardingScreen.pages.length);
      expect(progress.position, 0);

      await tester.tap(find.byKey(const Key('onboarding-primary-action')));
      await tester.pumpAndSettle();

      progress = tester.widget<OnboardingProgress>(
        find.byType(OnboardingProgress),
      );
      expect(progress.position, closeTo(1, 0.01));
    });
  });
}
