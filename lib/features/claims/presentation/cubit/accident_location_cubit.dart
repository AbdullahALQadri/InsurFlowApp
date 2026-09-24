import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/services/device_location_service.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_location.dart';

enum AccidentLocationStatus { idle, locating, ready, failed, confirming, confirmed }

/// State of capturing and confirming the inspection location.
class AccidentLocationState {
  const AccidentLocationState({
    required this.claimId,
    this.status = AccidentLocationStatus.idle,
    this.location,
    this.failure,
  });

  final String claimId;
  final AccidentLocationStatus status;

  /// The fix currently on screen. Null until one is acquired; never a
  /// placeholder.
  final DeviceLocation? location;

  final Failure? failure;

  bool get isBusy =>
      status == AccidentLocationStatus.locating ||
      status == AccidentLocationStatus.confirming;

  bool get hasLocation => location != null;

  /// Confirm is only meaningful once a real fix exists.
  bool get canConfirm => hasLocation && !isBusy;

  AccidentLocationState copyWith({
    AccidentLocationStatus? status,
    DeviceLocation? location,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AccidentLocationState(
      claimId: claimId,
      status: status ?? this.status,
      location: location ?? this.location,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Drives the accident-location step.
///
/// Acquires a real GPS fix, reverse geocodes it, and on confirmation
/// persists it with `PUT /claims/{id}/location` through the existing
/// [UpdateClaimLocationUseCase] — the claim on the backend is the
/// draft, so there is no second copy of this state to keep in sync.
class AccidentLocationCubit extends Cubit<AccidentLocationState> {
  AccidentLocationCubit({
    required String claimId,
    required DeviceLocationService locationService,
    required UpdateClaimLocationUseCase updateClaimLocationUseCase,
  }) : _locationService = locationService,
       _updateClaimLocationUseCase = updateClaimLocationUseCase,
       super(AccidentLocationState(claimId: claimId));

  final DeviceLocationService _locationService;
  final UpdateClaimLocationUseCase _updateClaimLocationUseCase;

  /// Acquires a fix. Used on open and by "Refresh Location", which is
  /// the same operation.
  Future<void> locate() async {
    if (state.status == AccidentLocationStatus.locating) return;
    emit(
      state.copyWith(
        status: AccidentLocationStatus.locating,
        clearFailure: true,
      ),
    );

    final result = await _locationService.currentLocation();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AccidentLocationStatus.failed,
          failure: failure,
        ),
      ),
      (location) => emit(
        AccidentLocationState(
          claimId: state.claimId,
          status: AccidentLocationStatus.ready,
          location: location,
        ),
      ),
    );
  }

  /// Persists the captured fix onto the claim.
  ///
  /// `PUT /claims/{id}/location` requires latitude, longitude, address
  /// and capturedAt. When the geocoder returned no address the
  /// coordinates are sent in its place, so the request stays valid
  /// without inventing a street name.
  Future<bool> confirm() async {
    final location = state.location;
    if (location == null || state.isBusy) return false;

    emit(
      state.copyWith(
        status: AccidentLocationStatus.confirming,
        clearFailure: true,
      ),
    );

    final result = await _updateClaimLocationUseCase(
      claimId: state.claimId,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address ?? location.coordinatesLabel,
      capturedAt: location.capturedAt,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AccidentLocationStatus.failed,
            failure: failure,
          ),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(status: AccidentLocationStatus.confirmed));
        return true;
      },
    );
  }

  Future<void> openSettings() => _locationService.openLocationSettings();
}
