import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/usecases/accept_assignment.dart';
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

/// The adjuster confirmed they are available to take the assignment.
class ClaimAssignmentAcceptRequested extends ClaimDetailsEvent {
  const ClaimAssignmentAcceptRequested();
}

/// The availability dialog has been shown. Declining emits this and
/// nothing else — no request is made.
class ClaimAcceptancePrompted extends ClaimDetailsEvent {
  const ClaimAcceptancePrompted();
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
    this.isAcceptingAssignment = false,
    this.acceptFailure,
    this.hasPromptedAcceptance = false,
  });

  final Claim claim;
  final bool isStarting;
  final Failure? startFailure;

  /// True while `POST /claims/{id}/accept-assignment` is in flight.
  final bool isAcceptingAssignment;
  final Failure? acceptFailure;

  /// Set once the availability dialog has been offered, so it is not
  /// re-shown on every rebuild after the adjuster declined.
  final bool hasPromptedAcceptance;

  ClaimDetailsLoadSuccess copyWith({
    Claim? claim,
    bool? isStarting,
    Failure? startFailure,
    bool clearStartFailure = false,
    bool? isAcceptingAssignment,
    Failure? acceptFailure,
    bool clearAcceptFailure = false,
    bool? hasPromptedAcceptance,
  }) {
    return ClaimDetailsLoadSuccess(
      claim ?? this.claim,
      isStarting: isStarting ?? this.isStarting,
      startFailure: clearStartFailure
          ? null
          : (startFailure ?? this.startFailure),
      isAcceptingAssignment:
          isAcceptingAssignment ?? this.isAcceptingAssignment,
      acceptFailure: clearAcceptFailure
          ? null
          : (acceptFailure ?? this.acceptFailure),
      hasPromptedAcceptance:
          hasPromptedAcceptance ?? this.hasPromptedAcceptance,
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
    required AcceptAssignmentUseCase acceptAssignmentUseCase,
  }) : _getClaimDetailsUseCase = getClaimDetailsUseCase,
       _startClaimUseCase = startClaimUseCase,
       _acceptAssignmentUseCase = acceptAssignmentUseCase,
       super(const ClaimDetailsInitial()) {
    on<ClaimDetailsRequested>(_onRequested);
    on<ClaimStartRequested>(_onStartRequested);
    on<ClaimAssignmentAcceptRequested>(_onAcceptRequested);
    on<ClaimAcceptancePrompted>(_onAcceptancePrompted);
  }

  final GetClaimDetailsUseCase _getClaimDetailsUseCase;
  final StartClaimUseCase _startClaimUseCase;
  final AcceptAssignmentUseCase _acceptAssignmentUseCase;

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

  Future<void> _onAcceptRequested(
    ClaimAssignmentAcceptRequested event,
    Emitter<ClaimDetailsState> emit,
  ) async {
    final current = state;
    if (current is! ClaimDetailsLoadSuccess) return;
    if (!current.claim.status.awaitsAcceptance) return;

    emit(
      current.copyWith(
        isAcceptingAssignment: true,
        clearAcceptFailure: true,
        hasPromptedAcceptance: true,
      ),
    );

    final result = await _acceptAssignmentUseCase(current.claim);
    result.fold(
      (failure) => emit(
        current.copyWith(
          isAcceptingAssignment: false,
          acceptFailure: failure,
          hasPromptedAcceptance: true,
        ),
      ),
      // The use case re-reads the claim, so this is the server's own
      // state: ASSIGNED, with the assignment populated.
      (claim) => emit(
        current.copyWith(
          claim: claim,
          isAcceptingAssignment: false,
          clearAcceptFailure: true,
          hasPromptedAcceptance: true,
        ),
      ),
    );
  }

  void _onAcceptancePrompted(
    ClaimAcceptancePrompted event,
    Emitter<ClaimDetailsState> emit,
  ) {
    final current = state;
    if (current is! ClaimDetailsLoadSuccess) return;
    if (current.hasPromptedAcceptance) return;
    emit(current.copyWith(hasPromptedAcceptance: true));
  }
}
