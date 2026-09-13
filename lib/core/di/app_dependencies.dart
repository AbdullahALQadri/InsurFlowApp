import 'package:dio/dio.dart';
import 'package:insurflow/core/network/dio_factory.dart';
import 'package:insurflow/core/network/secure_token_store.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:insurflow/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:insurflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/claims/data/datasources/claims_remote_data_source.dart';
import 'package:insurflow/features/claims/data/repositories/claims_repository_impl.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/usecases/get_claim_details.dart';
import 'package:insurflow/features/claims/domain/usecases/get_my_claims.dart';
import 'package:insurflow/features/claims/domain/usecases/lookup_vehicle.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';
import 'package:insurflow/features/claims/domain/usecases/submit_claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';

class AppDependencies {
  AppDependencies._({
    required this.tokenStore,
    required this.dio,
    required this.authRepository,
    required this.claimsRepository,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
    required this.getMyClaimsUseCase,
    required this.getClaimDetailsUseCase,
    required this.startClaimUseCase,
    required this.submitClaimUseCase,
    required this.lookupVehicleUseCase,
  });

  final TokenStore tokenStore;
  final Dio dio;
  final AuthRepository authRepository;
  final ClaimsRepository claimsRepository;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final GetMyClaimsUseCase getMyClaimsUseCase;
  final GetClaimDetailsUseCase getClaimDetailsUseCase;
  final StartClaimUseCase startClaimUseCase;
  final SubmitClaimUseCase submitClaimUseCase;
  final LookupVehicleUseCase lookupVehicleUseCase;

  static AppDependencies? _instance;

  static AppDependencies get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('AppDependencies.init() must be called first.');
    }
    return current;
  }

  static AppDependencies init({TokenStore? tokenStore}) {
    final store = tokenStore ?? SecureTokenStore();
    final dio = DioFactory.create(tokenStore: store);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dio),
      localDataSource: AuthLocalDataSourceImpl(store),
    );
    final claimsRepository = ClaimsRepositoryImpl(
      ClaimsRemoteDataSourceImpl(dio),
    );

    _instance = AppDependencies._(
      tokenStore: store,
      dio: dio,
      authRepository: authRepository,
      claimsRepository: claimsRepository,
      loginUseCase: LoginUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      restoreSessionUseCase: RestoreSessionUseCase(authRepository),
      getMyClaimsUseCase: GetMyClaimsUseCase(claimsRepository),
      getClaimDetailsUseCase: GetClaimDetailsUseCase(claimsRepository),
      startClaimUseCase: StartClaimUseCase(claimsRepository),
      submitClaimUseCase: SubmitClaimUseCase(claimsRepository),
      lookupVehicleUseCase: LookupVehicleUseCase(claimsRepository),
    );
    return _instance!;
  }

  static void reset() => _instance = null;

  AuthBloc createAuthBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      restoreSessionUseCase: restoreSessionUseCase,
    );
  }

  ClaimsBloc createClaimsBloc() {
    return ClaimsBloc(getMyClaimsUseCase: getMyClaimsUseCase);
  }

  ClaimDetailsBloc createClaimDetailsBloc() {
    return ClaimDetailsBloc(
      getClaimDetailsUseCase: getClaimDetailsUseCase,
      startClaimUseCase: startClaimUseCase,
    );
  }
}
