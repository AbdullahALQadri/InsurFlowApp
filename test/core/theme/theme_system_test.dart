import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_schemes.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_button_theme.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/tokens/app_metrics.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';

/// Every theme the app can run with, for checks that must hold in all of
/// them.
Map<String, ThemeData> _allThemes() => {
  'light': AppTheme.lightTheme,
  'dark': AppTheme.darkTheme,
  'custom light': AppTheme.custom(
    accent: const Color(0xFF7C3AED),
    brightness: Brightness.light,
  ),
  'custom dark': AppTheme.custom(
    accent: const Color(0xFF7C3AED),
    brightness: Brightness.dark,
  ),
};

void main() {
  group('token wiring', () {
    test('every theme carries the full token set', () {
      _allThemes().forEach((name, theme) {
        expect(theme.extension<AppColors>(), isNotNull, reason: name);
        expect(theme.extension<AppButtonTheme>(), isNotNull, reason: name);
        expect(theme.extension<AppSpacing>(), isNotNull, reason: name);
        expect(theme.extension<AppRadii>(), isNotNull, reason: name);
        expect(theme.extension<AppElevation>(), isNotNull, reason: name);
      });
    });

    test('brightness and material colour scheme agree with the tokens', () {
      _allThemes().forEach((name, theme) {
        final colors = theme.extension<AppColors>()!;
        expect(theme.colorScheme.brightness, theme.brightness, reason: name);
        expect(theme.colorScheme.primary, colors.primaryColor, reason: name);
        expect(theme.colorScheme.onPrimary, colors.onPrimaryColor, reason: name);
        expect(theme.scaffoldBackgroundColor, colors.backgroundColor,
            reason: name);
        expect(theme.colorScheme.surface, colors.cardColor, reason: name);
      });
    });

    test('component themes are defined in every theme', () {
      _allThemes().forEach((name, theme) {
        final colors = theme.extension<AppColors>()!;
        // App bars, cards, dialogs, sheets, navigation, inputs and
        // snackbars all follow the scheme rather than Material defaults.
        expect(theme.appBarTheme.backgroundColor, colors.backgroundColor,
            reason: name);
        expect(theme.cardTheme.color, colors.cardColor, reason: name);
        expect(theme.dialogTheme.backgroundColor, colors.cardColor,
            reason: name);
        expect(theme.bottomSheetTheme.modalBackgroundColor, colors.cardColor,
            reason: name);
        expect(theme.bottomSheetTheme.modalBarrierColor, colors.overlayScrim,
            reason: name);
        expect(
          theme.bottomNavigationBarTheme.selectedItemColor,
          colors.primaryColor,
          reason: name,
        );
        expect(theme.dividerTheme.color, colors.borderColor, reason: name);
        expect(theme.inputDecorationTheme.fillColor, colors.cardColor,
            reason: name);
        expect(theme.progressIndicatorTheme.color, colors.primaryColor,
            reason: name);
        expect(theme.textSelectionTheme.cursorColor, colors.primaryColor,
            reason: name);
        expect(theme.snackBarTheme.backgroundColor, isNotNull, reason: name);
        expect(theme.textTheme.bodyMedium?.color, colors.textPrimaryColor,
            reason: name);
      });
    });
  });

  group('contrast', () {
    /// WCAG AA for body text.
    const bodyText = 4.5;

    /// WCAG AA for large text, icons and UI components.
    const uiComponent = 3.0;

    double ratio(Color a, Color b) => AppColorSchemes.contrastRatio(a, b);

    test('primary text is readable on background and card', () {
      _allThemes().forEach((name, theme) {
        final c = theme.extension<AppColors>()!;
        expect(ratio(c.textPrimaryColor, c.backgroundColor),
            greaterThanOrEqualTo(bodyText), reason: '$name background');
        expect(ratio(c.textPrimaryColor, c.cardColor),
            greaterThanOrEqualTo(bodyText), reason: '$name card');
      });
    });

    test('secondary text stays legible', () {
      _allThemes().forEach((name, theme) {
        final c = theme.extension<AppColors>()!;
        expect(ratio(c.textSecondaryColor, c.cardColor),
            greaterThanOrEqualTo(uiComponent), reason: name);
      });
    });

    test('content on the primary fill is readable', () {
      _allThemes().forEach((name, theme) {
        final c = theme.extension<AppColors>()!;
        expect(ratio(c.onPrimaryColor, c.primaryColor),
            greaterThanOrEqualTo(uiComponent), reason: name);
      });
    });

    test('the accent itself is distinguishable from the surface', () {
      _allThemes().forEach((name, theme) {
        final c = theme.extension<AppColors>()!;
        expect(ratio(c.primaryColor, c.cardColor),
            greaterThanOrEqualTo(uiComponent), reason: name);
      });
    });

    test('feedback colours are usable on the card surface', () {
      _allThemes().forEach((name, theme) {
        final c = theme.extension<AppColors>()!;
        for (final entry in {
          'danger': c.dangerColor,
          'warning': c.warningColor,
          'success': c.successColor,
        }.entries) {
          expect(ratio(entry.value, c.cardColor),
              greaterThanOrEqualTo(2.0), reason: '$name ${entry.key}');
        }
      });
    });

    test('every preset accent survives the contrast pass', () {
      for (final accent in AppColorSchemes.presetAccents) {
        for (final brightness in Brightness.values) {
          final colors =
              AppColorSchemes.custom(accent: accent, brightness: brightness);
          expect(
            ratio(colors.primaryColor, colors.cardColor),
            greaterThanOrEqualTo(uiComponent),
            reason: '$accent on $brightness',
          );
          expect(
            ratio(colors.onPrimaryColor, colors.primaryColor),
            greaterThanOrEqualTo(uiComponent),
            reason: 'onPrimary for $accent on $brightness',
          );
        }
      }
    });

    test('an extreme accent is corrected rather than used raw', () {
      // Near-white would be invisible on a light card.
      final light = AppColorSchemes.custom(
        accent: const Color(0xFFFFFFF0),
        brightness: Brightness.light,
      );
      expect(light.primaryColor, isNot(const Color(0xFFFFFFF0)));
      expect(ratio(light.primaryColor, light.cardColor),
          greaterThanOrEqualTo(uiComponent));

      // Near-black would vanish on a dark card.
      final dark = AppColorSchemes.custom(
        accent: const Color(0xFF010101),
        brightness: Brightness.dark,
      );
      expect(ratio(dark.primaryColor, dark.cardColor),
          greaterThanOrEqualTo(uiComponent));
    });
  });

  group('custom theme derivation', () {
    test('a custom accent reaches primary, focus and buttons', () {
      const accent = Color(0xFFDB2777);
      final theme = AppTheme.custom(
        accent: accent,
        brightness: Brightness.light,
      );
      final colors = theme.extension<AppColors>()!;
      final buttons = theme.extension<AppButtonTheme>()!;

      expect(colors.inputFocusedBorderColor, colors.primaryColor);
      expect(buttons.outlinedForegroundColor, colors.primaryColor);
      expect(buttons.foregroundColor, colors.onPrimaryColor);
      // The primary button gradient is derived from the accent, not the
      // brand cyan.
      expect(
        buttons.backgroundGradient.colors.first,
        isNot(AppColorSchemes.light.primaryColor),
      );
    });

    test('surfaces and text stay on the base scheme', () {
      const accent = Color(0xFFDB2777);
      final custom =
          AppColorSchemes.custom(accent: accent, brightness: Brightness.dark);

      expect(custom.backgroundColor, AppColorSchemes.dark.backgroundColor);
      expect(custom.cardColor, AppColorSchemes.dark.cardColor);
      expect(custom.textPrimaryColor, AppColorSchemes.dark.textPrimaryColor);
    });

    test('immersive and brand tokens do not follow the accent', () {
      final custom = AppColorSchemes.custom(
        accent: const Color(0xFFDB2777),
        brightness: Brightness.light,
      );
      // Camera overlays must stay dark whatever the user picked.
      expect(custom.immersiveSurface, AppColorSchemes.light.immersiveSurface);
      expect(custom.brandSurfaceStart, AppColorSchemes.light.brandSurfaceStart);
    });
  });

  group('persistence and switching', () {
    test('accent round-trips through storage', () async {
      final store = InMemoryAppPreferencesStore();
      final cubit = AppPreferencesCubit(store: store);

      await cubit.setAccent(const Color(0xFF2563EB));
      await cubit.setThemeMode(ThemeMode.dark);

      final reloaded = AppPreferencesCubit(store: store);
      await reloaded.load();

      expect(reloaded.state.accentValue, const Color(0xFF2563EB).toARGB32());
      expect(reloaded.state.usesCustomAccent, isTrue);
      expect(reloaded.state.themeMode, ThemeMode.dark);

      await cubit.close();
      await reloaded.close();
    });

    test('clearing the accent returns to the default theme', () async {
      final cubit = AppPreferencesCubit(store: InMemoryAppPreferencesStore());

      await cubit.setAccent(const Color(0xFF2563EB));
      expect(cubit.state.usesCustomAccent, isTrue);

      await cubit.setAccent(null);
      expect(cubit.state.usesCustomAccent, isFalse);
      expect(cubit.state.accent, isNull);

      await cubit.close();
    });

    test('a malformed stored accent falls back to the brand colour', () {
      final preferences = AppPreferences.fromJson(const {
        'accentValue': 'not-an-int',
      });
      expect(preferences.accentValue, isNull);
      expect(preferences.usesCustomAccent, isFalse);
    });
  });

  group('a screen follows the active theme', () {
    /// A probe that reports the tokens a widget resolves, so the switch
    /// paths can be checked from inside the tree.
    Widget probe(void Function(AppColors, AppSpacing, AppRadii) report) {
      return Builder(
        builder: (context) {
          report(context.colors, context.spacing, context.radii);
          return Scaffold(
            appBar: AppBar(title: const Text('probe')),
            body: const Text('body'),
          );
        },
      );
    }

    Future<AppColors> pumpWith(
      WidgetTester tester, {
      required AppPreferences preferences,
    }) async {
      late AppColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: preferences.accent == null
              ? AppTheme.lightTheme
              : AppTheme.custom(
                  accent: preferences.accent!,
                  brightness: Brightness.light,
                ),
          darkTheme: preferences.accent == null
              ? AppTheme.darkTheme
              : AppTheme.custom(
                  accent: preferences.accent!,
                  brightness: Brightness.dark,
                ),
          themeMode: preferences.themeMode,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: probe((colors, _, _) => seen = colors),
        ),
      );
      await tester.pumpAndSettle();
      return seen;
    }

    testWidgets('light to dark and back', (tester) async {
      final light = await pumpWith(
        tester,
        preferences: const AppPreferences(themeMode: ThemeMode.light),
      );
      expect(light.backgroundColor, AppColorSchemes.light.backgroundColor);

      final dark = await pumpWith(
        tester,
        preferences: const AppPreferences(themeMode: ThemeMode.dark),
      );
      expect(dark.backgroundColor, AppColorSchemes.dark.backgroundColor);

      final backToLight = await pumpWith(
        tester,
        preferences: const AppPreferences(themeMode: ThemeMode.light),
      );
      expect(
        backToLight.backgroundColor,
        AppColorSchemes.light.backgroundColor,
      );
    });

    testWidgets('custom to light and custom to dark', (tester) async {
      final accent = const Color(0xFF7C3AED).toARGB32();

      final customLight = await pumpWith(
        tester,
        preferences: AppPreferences(
          themeMode: ThemeMode.light,
          accentValue: accent,
        ),
      );
      expect(customLight.primaryColor,
          isNot(AppColorSchemes.light.primaryColor));
      expect(customLight.backgroundColor,
          AppColorSchemes.light.backgroundColor);

      // Custom -> Light: the accent is cleared.
      final light = await pumpWith(
        tester,
        preferences: const AppPreferences(themeMode: ThemeMode.light),
      );
      expect(light.primaryColor, AppColorSchemes.light.primaryColor);

      // A custom accent under the dark brightness.
      final customDark = await pumpWith(
        tester,
        preferences: AppPreferences(
          themeMode: ThemeMode.dark,
          accentValue: accent,
        ),
      );
      expect(customDark.backgroundColor, AppColorSchemes.dark.backgroundColor);
      expect(customDark.primaryColor, isNot(AppColorSchemes.dark.primaryColor));

      // Custom -> Dark.
      final dark = await pumpWith(
        tester,
        preferences: const AppPreferences(themeMode: ThemeMode.dark),
      );
      expect(dark.primaryColor, AppColorSchemes.dark.primaryColor);
    });

    testWidgets('spacing and radius tokens resolve without a fallback', (
      tester,
    ) async {
      late AppSpacing spacing;
      late AppRadii radii;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: probe((_, s, r) {
            spacing = s;
            radii = r;
          }),
        ),
      );
      await tester.pump();

      expect(spacing.screenHorizontal, AppSpacing.standard.screenHorizontal);
      expect(radii.card, AppRadii.standard.card);
    });
  });
}
