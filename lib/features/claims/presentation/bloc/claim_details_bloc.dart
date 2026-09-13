import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/usecases/get_claim_details.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';

sealed class ClaimDetailsEvent {
  const ClaimDetailsEvent();
}

class ClaimDetailsRequested extends ClaimDetailsEvent {
  const ClaimDetailsRequested(this.claimId);

  final String claimId;
}

class ClaimStartRequested extends ClaimDetailsEvent {
  const ClaimStartRequested();
}

sealed class ClaimDetailsState {
  const ClaimDetailsState();
}

class ClaimDetailsInitial extends ClaimDetailsState {
  const ClaimDetailsInitial();
}

class ClaimDetailsLoadInProgress extends ClaimDetailsState {
  const ClaimDetailsLoadInProgress();
}

class ClaimDetailsLoadSuccess extends ClaimDetailsState {
  const ClaimDetailsLoadSuccess(
    this.claim, {
    this.isStarting = false,
    this.startFailure,
  });

  final Claim claim;
  final bool isStarting;
  final Failure? startFailure;

  ClaimDetailsLoadSuccess copyWith({
    Claim? claim,
    bool? isStarting,
    Failure? startFailure,
    bool clearStartFailure = false,
  }) {
    return ClaimDetailsLoadSuccess(
      claim ?? this.claim,
      isStarting: isStarting ?? this.isStarting,
      startFailure: clearStartFailure
          ? null
          : (startFailure ?? this.startFailure),
    );
  }
}

class ClaimDetailsLoadFailure extends ClaimDetailsState {
  const ClaimDetailsLoadFailure(this.failure);

  final Failure failure;
}

class ClaimDetailsStarted extends ClaimDetailsState {
  const ClaimDetailsStarted(this.claim);

  final Claim claim;
}

class ClaimDetailsBloc extends Bloc<ClaimDetailsEvent, ClaimDetailsState> {
  ClaimDetailsBloc({
    required GetClaimDetailsUseCase getClaimDetailsUseCase,
    required StartClaimUseCase startClaimUseCase,
  }) : _getClaimDetailsUseCase = getClaimDetailsUseCase,
       _startClaimUseCase = startClaimUseCase,
       super(const ClaimDetailsInitial()) {
    on<ClaimDetailsRequested>(_onRequested);
    on<ClaimStartRequested>(_onStartRequested);
  }

  final GetClaimDetailsUseCase _getClaimDetailsUseCase;
  final StartClaimUseCase _startClaimUseCase;

  Future<void> _onRequested(
    ClaimDetailsRequested event,
    Emitter<ClaimDetailsState> emit,
  ) async {
    emit(const ClaimDetailsLoadInProgress());
    final result = await _getClaimDetailsUseCase(event.claimId);
    result.fold(
      (failure) => emit(ClaimDetailsLoadFailure(failure)),
      (claim) => emit(ClaimDetailsLoadSuccess(claim)),
    );
  }

  Future<void> _onStartRequested(
    ClaimStartRequested event,
    Emitter<ClaimDetailsState> emit,
  ) async {
    final current = state;
    if (current is! ClaimDetailsLoadSuccess) return;

    emit(current.copyWith(isStarting: true, clearStartFailure: true));
    final result = await _startClaimUseCase(current.claim);
    result.fold(
      (failure) =>
          emit(current.copyWith(isStarting: false, startFailure: failure)),
      (claim) {
        InspectionProgress.start(claim.id);
        emit(ClaimDetailsStarted(claim));
      },
    );
  }
}
