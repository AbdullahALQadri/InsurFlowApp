import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/authentication/presentation/screens/login_screen.dart';
import 'package:insurflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:insurflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:insurflow/main.dart';

/// The splash holds for this long before routing on.
const splashHold = Duration(milliseconds: 3400);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppDependencies.reset);

  /// Boots the app with a given stored state, as a launch would.
  Future<void> launch(
    WidgetTester tester, {
    required AppPreferences stored,
    String? accessToken,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tokens = InMemoryTokenStore();
    if (accessToken != null) await tokens.saveAccessToken(accessToken);

    AppDependencies.reset();
    AppDependencies.init(
      tokenStore: tokens,
      preferencesStore: InMemoryAppPreferencesStore(stored),
    );

    await tester.pumpWidget(const InsurFlowApp());
    await tester.pump();
    // The splash animates continuously, so advance time explicitly
    // rather than settling.
    await tester.pump(splashHold);
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a fresh install shows onboarding before sign-in', (
    tester,
  ) async {
    await launch(
      tester,
      stored: const AppPreferences(isLoaded: true),
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('after onboarding is done the app goes straight to sign-in', (
    tester,
  ) async {
    await launch(
      tester,
      stored: const AppPreferences(
        hasCompletedOnboarding: true,
        isLoaded: true,
      ),
    );

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('an existing session never sees onboarding', (tester) async {
    // Signed in, and the flag was never written — they have clearly
    // used the app before, so onboarding would be wrong here.
    await launch(
      tester,
      stored: const AppPreferences(isLoaded: true),
      accessToken: 'jwt-token',
    );

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('the splash waits for preferences before deciding', (
    tester,
  ) async {
    // isLoaded false stands in for a read still in flight: the splash
    // must hold rather than route on defaults.
    AppDependencies.reset();
    AppDependencies.init(
      tokenStore: InMemoryTokenStore(),
      preferencesStore: _NeverLoadingStore(),
    );

    await tester.pumpWidget(const InsurFlowApp());
    await tester.pump();
    await tester.pump(splashHold);
    await tester.pump(const Duration(milliseconds: 400));

    // Still on the splash: nothing was decided from defaults.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

/// A store whose read never reports as loaded.
class _NeverLoadingStore implements AppPreferencesStore {
  @override
  Future<AppPreferences> read() async => const AppPreferences();

  @override
  Future<void> write(AppPreferences preferences) async {}
}
