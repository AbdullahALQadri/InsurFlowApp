import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockRestoreSessionUseCase extends Mock
    implements RestoreSessionUseCase {}

class _FakeLoginParams extends Fake implements LoginParams {}

class _FakeNoParams extends Fake implements NoParams {}

void main() {
  late _MockLoginUseCase loginUseCase;
  late _MockLogoutUseCase logoutUseCase;
  late _MockRestoreSessionUseCase restoreSessionUseCase;

  setUpAll(() {
    registerFallbackValue(_FakeLoginParams());
    registerFallbackValue(_FakeNoParams());
  });

  setUp(() {
    loginUseCase = _MockLoginUseCase();
    logoutUseCase = _MockLogoutUseCase();
    restoreSessionUseCase = _MockRestoreSessionUseCase();
  });

  AuthBloc buildBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      restoreSessionUseCase: restoreSessionUseCase,
    );
  }

  final session = testSession();

  blocTest<AuthBloc, AuthState>(
    'emits authenticated when login succeeds',
    build: () {
      when(() => loginUseCase(any())).thenAnswer((_) async => Right(session));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(
        organizationCode: 'DEMO-INS',
        employeeCode: 'CO-001',
        password: 'Password123!',
      ),
    ),
    expect: () => [
      isA<AuthLoadInProgress>(),
      isA<AuthAuthenticated>().having(
        (state) => state.session.accessToken,
        'token',
        session.accessToken,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated with UnauthorizedFailure for invalid credentials',
    build: () {
      when(
        () => loginUseCase(any()),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(
        organizationCode: 'DEMO-INS',
        employeeCode: 'CO-001',
        password: 'wrong',
      ),
    ),
    expect: () => [
      isA<AuthLoadInProgress>(),
      isA<AuthUnauthenticated>().having(
        (state) => state.failure,
        'failure',
        isA<UnauthorizedFailure>(),
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated with NetworkFailure when login cannot reach the API',
    build: () {
      when(
        () => loginUseCase(any()),
      ).thenAnswer((_) async => const Left(NetworkFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(
        organizationCode: 'DEMO-INS',
        employeeCode: 'CO-001',
        password: 'Password123!',
      ),
    ),
    expect: () => [
      isA<AuthLoadInProgress>(),
      isA<AuthUnauthenticated>().having(
        (state) => state.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    ],
  );
}
