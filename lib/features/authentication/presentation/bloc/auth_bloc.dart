import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:insurflow/core/services/adjuster_position_store.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthSessionRequested extends AuthEvent {
  const AuthSessionRequested();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({
    required this.organizationCode,
    required this.employeeCode,
    required this.password,
  });

  final String organizationCode;
  final String employeeCode;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoadInProgress extends AuthState {
  const AuthLoadInProgress();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.failure});

  final Failure? failure;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    LocationTrackingService? locationTrackingService,
    AdjusterPositionStore? adjusterPositionStore,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _restoreSessionUseCase = restoreSessionUseCase,
       _locationTrackingService = locationTrackingService,
       _adjusterPositionStore = adjusterPositionStore,
       super(const AuthInitial()) {
    on<AuthSessionRequested>(_onSessionRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  /// Optional so existing tests can build the bloc without them; both
  /// are torn down on sign-out.
  final LocationTrackingService? _locationTrackingService;
  final AdjusterPositionStore? _adjusterPositionStore;

  Future<void> _onSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    final result = await _restoreSessionUseCase(const NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (session) => emit(
        session == null
            ? const AuthUnauthenticated()
            : AuthAuthenticated(session),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    final result = await _loginUseCase(
      LoginParams(
        organizationCode: event.organizationCode,
        employeeCode: event.employeeCode,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthUnauthenticated(failure: failure)),
      (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase(const NoParams());
    // Stop reporting a position and drop the last fix, so the next
    // user to sign in does not inherit this one's coordinates.
    _locationTrackingService?.stop();
    _adjusterPositionStore?.clear();
    emit(const AuthUnauthenticated());
  }
}
