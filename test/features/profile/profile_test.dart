import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:insurflow/features/authentication/data/models/auth_session_model.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:insurflow/features/authentication/domain/usecases/change_password_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';
import 'package:insurflow/features/profile/presentation/screens/change_password_screen.dart';
import 'package:insurflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:insurflow/features/profile/presentation/widgets/sign_out_dialog.dart';

/// The exact `data` block `POST /auth/login` returns for FA-001.
const loginResponse = {
  'success': true,
  'message': 'Login successful',
  'data': {
    'accessToken': 'jwt-token',
    'user': {
      'id': '6aa27838cda4d3dca00b83ad',
      'name': 'Ahmed Adjuster',
      'employeeCode': 'FA-001',
      'role': 'FIELD_ADJUSTER',
      'organizationId': '6a919f45e62778a597174333',
      'organizationName': 'Demo Insurance Co',
    },
  },
};

AuthSession _session() {
  return AuthSessionModel.fromResponse(
    loginResponse,
    organizationCode: 'DEMO-INS',
  )!.toEntity();
}

void main() {
  group('login response parsing', () {
    test('reads every field the backend actually returns', () {
      final session = _session();

      expect(session.accessToken, 'jwt-token');
      expect(session.userId, '6aa27838cda4d3dca00b83ad');
      expect(session.displayName, 'Ahmed Adjuster');
      expect(session.employeeCode, 'FA-001');
      expect(session.role, 'FIELD_ADJUSTER');
      expect(session.organizationId, '6a919f45e62778a597174333');
      expect(session.organizationName, 'Demo Insurance Co');
      // Not returned by the backend; carried from the login form.
      expect(session.organizationCode, 'DEMO-INS');
    });

    test('a response without a token is not a session', () {
      expect(
        AuthSessionModel.fromResponse(const {'data': <String, dynamic>{}}),
        isNull,
      );
      expect(AuthSessionModel.fromResponse(null), isNull);
    });

    test('initial comes from the real name, never invented', () {
      expect(_session().initial, 'A');
      const empty = AuthSession(accessToken: 't');
      expect(empty.initial, isNull);
      expect(empty.displayNameOrCode, isNull);
    });
  });

  group('session persistence', () {
    test('the full user survives a restart, not just the token', () async {
      final store = InMemoryTokenStore();
      final local = AuthLocalDataSourceImpl(store);

      await local.saveSession(_session());
      final restored = await local.readSession();

      // Before this change only the token was kept and Profile fell
      // back to a placeholder name.
      expect(restored!.displayName, 'Ahmed Adjuster');
      expect(restored.employeeCode, 'FA-001');
      expect(restored.role, 'FIELD_ADJUSTER');
      expect(restored.organizationName, 'Demo Insurance Co');
      expect(restored.userId, '6aa27838cda4d3dca00b83ad');
      expect(restored.organizationCode, 'DEMO-INS');
    });

    test('sign-out clears the token and the stored user', () async {
      final store = InMemoryTokenStore();
      final local = AuthLocalDataSourceImpl(store);

      await local.saveSession(_session());
      await local.clear();

      expect(await local.readSession(), isNull);
      expect(await store.readAccessToken(), isNull);
      expect(await store.readSession(), isNull);
    });

    test('a corrupt stored payload still signs the user in', () async {
      final store = InMemoryTokenStore();
      await store.saveAccessToken('jwt-token');
      await store.saveSession('}{ not json');

      final restored = await AuthLocalDataSourceImpl(store).readSession();

      expect(restored, isNotNull);
      expect(restored!.accessToken, 'jwt-token');
      expect(restored.displayName, isNull);
    });

    test('no token means no session, whatever else is stored', () async {
      final store = InMemoryTokenStore();
      await store.saveSession(jsonEncode({'displayName': 'Ghost'}));

      expect(await AuthLocalDataSourceImpl(store).readSession(), isNull);
    });
  });

  group('change password', () {
    test('sends the exact contract the backend validates', () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _StubAdapter(requests);

      await _repository(dio).changePassword(
        currentPassword: 'Password123!',
        newPassword: 'NewPassword123!',
      );

      expect(requests.single.method, 'PUT');
      expect(requests.single.path, '/auth/change-password');
      expect(requests.single.data, {
        'currentPassword': 'Password123!',
        'newPassword': 'NewPassword123!',
      });
    });

    test('the client minimum matches the server rule', () {
      // The backend rejects anything shorter than 8 and enforces no
      // complexity rule beyond that.
      expect(ChangePasswordUseCase.minPasswordLength, 8);
    });
  });

  group('app preferences', () {
    test('default to following the device', () {
      const preferences = AppPreferences();
      expect(preferences.themeMode, ThemeMode.system);
      expect(preferences.locale, isNull);
      expect(preferences.followsSystemLanguage, isTrue);
    });

    test('changes are persisted and reloaded', () async {
      final store = InMemoryAppPreferencesStore();
      final cubit = AppPreferencesCubit(store: store);

      await cubit.setThemeMode(ThemeMode.dark);
      await cubit.setLocale('ar');

      final reloaded = AppPreferencesCubit(store: store);
      await reloaded.load();

      expect(reloaded.state.themeMode, ThemeMode.dark);
      expect(reloaded.state.localeCode, 'ar');
      expect(reloaded.state.locale, const Locale('ar'));

      await cubit.close();
      await reloaded.close();
    });

    test('returning to system language clears the override', () async {
      final cubit = AppPreferencesCubit(store: InMemoryAppPreferencesStore());

      await cubit.setLocale('ar');
      expect(cubit.state.localeCode, 'ar');

      await cubit.setLocale(null);
      expect(cubit.state.localeCode, isNull);
      expect(cubit.state.locale, isNull);

      await cubit.close();
    });

    test('an unsupported stored language falls back to system', () {
      final preferences = AppPreferences.fromJson(const {
        'localeCode': 'fr',
        'themeMode': 'nonsense',
      });
      expect(preferences.localeCode, isNull);
      expect(preferences.themeMode, ThemeMode.system);
    });
  });

  group('profile screen', () {
    late _FakeAuthRepository repository;
    late AuthBloc authBloc;
    late AppPreferencesCubit preferencesCubit;

    setUp(() {
      repository = _FakeAuthRepository();
      authBloc = AuthBloc(
        loginUseCase: LoginUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        restoreSessionUseCase: RestoreSessionUseCase(repository),
      );
      preferencesCubit = AppPreferencesCubit(
        store: InMemoryAppPreferencesStore(),
      );
    });

    tearDown(() async {
      await authBloc.close();
      await preferencesCubit.close();
    });

    Widget wrap({Locale locale = const Locale('en'), ThemeData? theme}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: preferencesCubit),
          BlocProvider<NotificationCenterCubit>(
            create: (_) => _StubNotificationCubit(),
          ),
        ],
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
          home: const ProfileScreen(),
        ),
      );
    }

    Future<void> pump(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
      ThemeData? theme,
      Size size = const Size(1080, 2400),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      authBloc.emit(AuthAuthenticated(_session()));
      await tester.pumpWidget(wrap(locale: locale, theme: theme));
      await tester.pump();
    }

    testWidgets('shows only real values from the login response', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Ahmed Adjuster'), findsWidgets);
      expect(find.text('FA-001'), findsOneWidget);
      // Role is the backend enum, re-cased for reading.
      expect(find.text('Field Adjuster'), findsWidgets);
      expect(find.text('Demo Insurance Co'), findsOneWidget);
      expect(find.text('DEMO-INS'), findsOneWidget);
      expect(find.text('6aa27838cda4d3dca00b83ad'), findsOneWidget);
    });

    testWidgets('shows no email or phone — the API returns neither', (
      tester,
    ) async {
      await pump(tester);

      for (final label in ['Email', 'E-mail', 'Phone', 'Mobile']) {
        expect(
          find.text(label, skipOffstage: false),
          findsNothing,
          reason: '$label is not in any mobile endpoint',
        );
      }
    });

    testWidgets('omits rows the backend did not provide', (tester) async {
      authBloc.emit(const AuthAuthenticated(AuthSession(accessToken: 't')));
      await tester.pumpWidget(wrap());
      await tester.pump();

      // No name, code, role or organization came back, so those rows do
      // not render at all rather than showing placeholders.
      expect(find.text('Full name'), findsNothing);
      expect(find.text('Employee code'), findsNothing);
      expect(find.text('Organization'), findsNothing);
      expect(find.text('Not provided by the backend.'), findsOneWidget);
    });

    testWidgets('language and theme rows reflect the saved preference', (
      tester,
    ) async {
      await preferencesCubit.setThemeMode(ThemeMode.dark);
      await preferencesCubit.setLocale('en');
      await pump(tester);

      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('changing the theme persists it', (tester) async {
      await pump(tester);

      await tester.ensureVisible(find.byKey(const Key('profile-theme')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-theme')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.themeMode, ThemeMode.dark);
    });

    testWidgets('dismissing the sheet leaves the preference unchanged', (
      tester,
    ) async {
      await pump(tester);
      final before = preferencesCubit.state.themeMode;

      await tester.ensureVisible(find.byKey(const Key('profile-theme')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-theme')));
      await tester.pumpAndSettle();
      // Tap outside the sheet to dismiss it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.themeMode, before);
    });

    testWidgets('renders in Arabic, right to left', (tester) async {
      await pump(tester, locale: const Locale('ar'));

      expect(find.text('الملف الشخصي'), findsNothing); // no app bar title
      expect(find.text('الاسم الكامل'), findsOneWidget);
      expect(find.text('المؤسسة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('الاسم الكامل'))),
        TextDirection.rtl,
      );
    });

    testWidgets('renders under the dark theme', (tester) async {
      await pump(tester, theme: AppTheme.darkTheme);

      expect(find.text('Ahmed Adjuster'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out on small and large screens', (tester) async {
      for (final size in const [Size(720, 1280), Size(1440, 3200)]) {
        await pump(tester, size: size);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('sign out', () {
    late _FakeAuthRepository repository;
    late AuthBloc authBloc;

    setUp(() {
      repository = _FakeAuthRepository();
      authBloc = AuthBloc(
        loginUseCase: LoginUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        restoreSessionUseCase: RestoreSessionUseCase(repository),
      );
    });

    tearDown(() => authBloc.close());

    Future<void> pumpDialogHost(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      authBloc.emit(AuthAuthenticated(_session()));
      await tester.pumpWidget(
        BlocProvider.value(
          value: authBloc,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppStringsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('open-sign-out'),
                    onPressed: () => SignOutDialog.confirmAndSignOut(context),
                    child: const Text('Sign out'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('requires explicit confirmation', (tester) async {
      await pumpDialogHost(tester);

      await tester.tap(find.byKey(const Key('open-sign-out')));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      // Nothing has happened yet.
      expect(repository.logoutCalls, 0);

      await tester.tap(find.byKey(const Key('sign-out-cancel')));
      await tester.pumpAndSettle();

      expect(repository.logoutCalls, 0);
      expect(authBloc.state, isA<AuthAuthenticated>());
    });

    testWidgets('confirming runs the real logout and clears the session', (
      tester,
    ) async {
      await pumpDialogHost(tester);

      await tester.tap(find.byKey(const Key('open-sign-out')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sign-out-confirm')));
      await tester.pumpAndSettle();
      // The handler awaits the logout use case before emitting, so let
      // the real async work complete before reading the state.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      // The real logout use case ran — not a local-only reset — and the
      // bloc moved the app out of the authenticated state.
      expect(repository.logoutCalls, 1);
      expect(authBloc.state, isA<AuthUnauthenticated>());
    });

    testWidgets('dismissing the dialog does not sign out', (tester) async {
      await pumpDialogHost(tester);

      await tester.tap(find.byKey(const Key('open-sign-out')));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('Sign out?'))).pop();
      await tester.pumpAndSettle();

      expect(repository.logoutCalls, 0);
      expect(authBloc.state, isA<AuthAuthenticated>());
    });
  });

  group('change password screen', () {
    Widget wrap(ChangePasswordScreen screen) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStringsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      );
    }

    testWidgets('rejects a password shorter than the server minimum', (
      tester,
    ) async {
      var submitted = false;
      await tester.pumpWidget(
        wrap(
          ChangePasswordScreen(
            onSubmit: (_, _) async {
              submitted = true;
              return true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('current-password-field')),
          matching: find.byType(TextField),
        ),
        'Password123!',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('new-password-field')),
          matching: find.byType(TextField),
        ),
        'short',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('confirm-password-field')),
          matching: find.byType(TextField),
        ),
        'short',
      );
      await tester.tap(find.byKey(const Key('change-password-submit')));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters.'),
          findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('rejects a mismatched confirmation', (tester) async {
      var submitted = false;
      await tester.pumpWidget(
        wrap(
          ChangePasswordScreen(
            onSubmit: (_, _) async {
              submitted = true;
              return true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('current-password-field')),
          matching: find.byType(TextField),
        ),
        'Password123!',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('new-password-field')),
          matching: find.byType(TextField),
        ),
        'NewPassword1',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('confirm-password-field')),
          matching: find.byType(TextField),
        ),
        'DifferentOne1',
      );
      await tester.tap(find.byKey(const Key('change-password-submit')));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('surfaces a wrong current password from the server', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(ChangePasswordScreen(onSubmit: (_, _) async => false)),
      );
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('current-password-field')),
          matching: find.byType(TextField),
        ),
        'WrongPassword',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('new-password-field')),
          matching: find.byType(TextField),
        ),
        'NewPassword1',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('confirm-password-field')),
          matching: find.byType(TextField),
        ),
        'NewPassword1',
      );
      await tester.tap(find.byKey(const Key('change-password-submit')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Current password is incorrect.'), findsOneWidget);
    });

    testWidgets('a valid form submits', (tester) async {
      String? sentCurrent;
      String? sentNew;
      await tester.pumpWidget(
        wrap(
          ChangePasswordScreen(
            onSubmit: (current, next) async {
              sentCurrent = current;
              sentNew = next;
              return true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('current-password-field')),
          matching: find.byType(TextField),
        ),
        'Password123!',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('new-password-field')),
          matching: find.byType(TextField),
        ),
        'NewPassword1',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('confirm-password-field')),
          matching: find.byType(TextField),
        ),
        'NewPassword1',
      );
      await tester.tap(find.byKey(const Key('change-password-submit')));
      await tester.pump();
      await tester.pump();

      expect(sentCurrent, 'Password123!');
      expect(sentNew, 'NewPassword1');
    });
  });
}

// --- doubles ---------------------------------------------------------------

_AuthRepositoryForDio _repository(Dio dio) => _AuthRepositoryForDio(dio);

class _AuthRepositoryForDio {
  _AuthRepositoryForDio(this._dio);

  final Dio _dio;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _dio.put<dynamic>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  var logoutCalls = 0;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
  }) async => Right(_session());

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() async =>
      Right(_session());

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalls++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Right(null);
}

class _StubNotificationCubit extends Cubit<NotificationCenterState>
    implements NotificationCenterCubit {
  _StubNotificationCubit() : super(const NotificationCenterState());

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"success":true,"message":"Password changed successfully",'
      '"data":{"message":"Password changed successfully"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
