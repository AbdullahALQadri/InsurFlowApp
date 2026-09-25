import 'package:dio/dio.dart';
import 'package:insurflow/core/network/dio_factory.dart';
import 'package:insurflow/core/network/secure_token_store.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:insurflow/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/authentication/domain/usecases/change_password_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';
import 'package:insurflow/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:insurflow/features/authentication/domain/usecases/restore_session_usecase.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/claims/data/datasources/claims_remote_data_source.dart';
import 'package:insurflow/features/claims/data/repositories/claims_repository_impl.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/usecases/accept_assignment.dart';
import 'package:insurflow/features/claims/domain/usecases/decline_assignment.dart';
import 'package:insurflow/features/claims/domain/usecases/get_claim_details.dart';
import 'package:insurflow/features/claims/domain/usecases/get_my_claims.dart';
import 'package:insurflow/features/claims/domain/usecases/lookup_vehicle.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';
import 'package:insurflow/features/claims/domain/usecases/submit_claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/cubit/accident_location_cubit.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';

import 'package:insurflow/core/services/adjuster_position_store.dart';
import 'package:insurflow/core/services/device_location_service.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:insurflow/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:insurflow/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:insurflow/features/notifications/domain/usecases/register_device_token.dart';
import 'package:insurflow/features/notifications/presentation/cubit/notification_center_cubit.dart';
import 'package:insurflow/features/claims/domain/usecases/get_adjuster_stats.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_accident.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_location.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_vehicle.dart';
import 'package:insurflow/features/claims/domain/usecases/upload_claim_evidence.dart';
import 'package:insurflow/features/claims/domain/usecases/upload_claim_signature.dart';
import 'package:insurflow/features/home/presentation/cubit/home_cubit.dart';

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
    required this.acceptAssignmentUseCase,
    required this.declineAssignmentUseCase,
    required this.startClaimUseCase,
    required this.submitClaimUseCase,
    required this.lookupVehicleUseCase,
    required this.updateClaimVehicleUseCase,
    required this.updateClaimAccidentUseCase,
    required this.updateClaimLocationUseCase,
    required this.uploadClaimEvidenceUseCase,
    required this.uploadClaimSignatureUseCase,
    required this.getAdjusterStatsUseCase,
    required this.locationTrackingService,
    required this.deviceLocationService,
    required this.adjusterPositionStore,
    required this.notificationsRepository,
    required this.registerDeviceTokenUseCase,
    required this.pushNotificationService,
    required this.changePasswordUseCase,
    required this.appPreferencesStore,
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
  final AcceptAssignmentUseCase acceptAssignmentUseCase;
  final DeclineAssignmentUseCase declineAssignmentUseCase;
  final StartClaimUseCase startClaimUseCase;
  final SubmitClaimUseCase submitClaimUseCase;
  final LookupVehicleUseCase lookupVehicleUseCase;
  final UpdateClaimVehicleUseCase updateClaimVehicleUseCase;
  final UpdateClaimAccidentUseCase updateClaimAccidentUseCase;
  final UpdateClaimLocationUseCase updateClaimLocationUseCase;
  final UploadClaimEvidenceUseCase uploadClaimEvidenceUseCase;
  final UploadClaimSignatureUseCase uploadClaimSignatureUseCase;
  final GetAdjusterStatsUseCase getAdjusterStatsUseCase;
  final LocationTrackingService locationTrackingService;
  final DeviceLocationService deviceLocationService;

  /// The adjuster's latest fix, attached to requests as headers.
  final AdjusterPositionStore adjusterPositionStore;
  final NotificationsRepository notificationsRepository;
  final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  final PushNotificationService pushNotificationService;
  final ChangePasswordUseCase changePasswordUseCase;
  final AppPreferencesStore appPreferencesStore;

  static AppDependencies? _instance;

  static AppDependencies get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('AppDependencies.init() must be called first.');
    }
    return current;
  }

  /// [preferencesStore] is injectable for the same reason as
  /// [tokenStore]: tests need a store that does not touch the device
  /// keychain.
  static AppDependencies init({
    TokenStore? tokenStore,
    AppPreferencesStore? preferencesStore,
  }) {
    final store = tokenStore ?? SecureTokenStore();
    final positionStore = AdjusterPositionStore();
    final dio = DioFactory.create(
      tokenStore: store,
      positionStore: positionStore,
    );
    const deviceLocationService = GeolocatorLocationService();
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dio),
      localDataSource: AuthLocalDataSourceImpl(store),
    );
    final claimsRepository = ClaimsRepositoryImpl(
      ClaimsRemoteDataSourceImpl(dio),
    );
    final updateClaimLocation = UpdateClaimLocationUseCase(claimsRepository);
    // Refreshes the adjuster's position for the X-Latitude /
    // X-Longitude headers. It issues no request of its own.
    final trackingService = LocationTrackingService(
      locationService: deviceLocationService,
      positionStore: positionStore,
    );
    final notificationsRepository = NotificationsRepositoryImpl(
      NotificationsRemoteDataSourceImpl(dio),
    );
    final registerDeviceToken = RegisterDeviceTokenUseCase(
      notificationsRepository,
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
      acceptAssignmentUseCase: AcceptAssignmentUseCase(claimsRepository),
      declineAssignmentUseCase: DeclineAssignmentUseCase(claimsRepository),
      startClaimUseCase: StartClaimUseCase(claimsRepository),
      submitClaimUseCase: SubmitClaimUseCase(claimsRepository),
      lookupVehicleUseCase: LookupVehicleUseCase(claimsRepository),
      updateClaimVehicleUseCase: UpdateClaimVehicleUseCase(claimsRepository),
      updateClaimAccidentUseCase: UpdateClaimAccidentUseCase(claimsRepository),
      updateClaimLocationUseCase: updateClaimLocation,
      uploadClaimEvidenceUseCase: UploadClaimEvidenceUseCase(claimsRepository),
      uploadClaimSignatureUseCase: UploadClaimSignatureUseCase(claimsRepository),
      getAdjusterStatsUseCase: GetAdjusterStatsUseCase(claimsRepository),
      locationTrackingService: trackingService,
      deviceLocationService: deviceLocationService,
      adjusterPositionStore: positionStore,
      notificationsRepository: notificationsRepository,
      registerDeviceTokenUseCase: registerDeviceToken,
      pushNotificationService: PushNotificationService(
        registerDeviceTokenUseCase: registerDeviceToken,
      ),
      changePasswordUseCase: ChangePasswordUseCase(authRepository),
      appPreferencesStore: preferencesStore ?? SecureAppPreferencesStore(),
    );
    return _instance!;
  }

  static void reset() => _instance = null;

  AuthBloc createAuthBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      restoreSessionUseCase: restoreSessionUseCase,
      locationTrackingService: locationTrackingService,
      adjusterPositionStore: adjusterPositionStore,
    );
  }

  ClaimsBloc createClaimsBloc() {
    return ClaimsBloc(getMyClaimsUseCase: getMyClaimsUseCase);
  }

  ClaimDetailsBloc createClaimDetailsBloc() {
    return ClaimDetailsBloc(
      getClaimDetailsUseCase: getClaimDetailsUseCase,
      startClaimUseCase: startClaimUseCase,
      acceptAssignmentUseCase: acceptAssignmentUseCase,
      declineAssignmentUseCase: declineAssignmentUseCase,
    );
  }

  AppPreferencesCubit createAppPreferencesCubit() {
    return AppPreferencesCubit(store: appPreferencesStore);
  }

  AccidentLocationCubit createAccidentLocationCubit(String claimId) {
    return AccidentLocationCubit(
      claimId: claimId,
      locationService: deviceLocationService,
      updateClaimLocationUseCase: updateClaimLocationUseCase,
    );
  }

  NotificationCenterCubit createNotificationCenterCubit() {
    return NotificationCenterCubit(service: pushNotificationService);
  }

  HomeCubit createHomeCubit() {
    return HomeCubit(
      getMyClaimsUseCase: getMyClaimsUseCase,
      getAdjusterStatsUseCase: getAdjusterStatsUseCase,
    );
  }
}
