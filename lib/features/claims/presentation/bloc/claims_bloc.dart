import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/usecases/get_my_claims.dart';

sealed class ClaimsEvent {
  const ClaimsEvent();
}

class ClaimsRequested extends ClaimsEvent {
  const ClaimsRequested({this.statusFilter});

  final String? statusFilter;
}

class ClaimsRefreshed extends ClaimsEvent {
  const ClaimsRefreshed({this.statusFilter});

  final String? statusFilter;
}

sealed class ClaimsState {
  const ClaimsState();
}

class ClaimsInitial extends ClaimsState {
  const ClaimsInitial();
}

class ClaimsLoadInProgress extends ClaimsState {
  const ClaimsLoadInProgress();
}

class ClaimsRefreshInProgress extends ClaimsState {
  const ClaimsRefreshInProgress(this.claims);

  final List<Claim> claims;
}

class ClaimsLoadSuccess extends ClaimsState {
  const ClaimsLoadSuccess(this.claims, {this.activeFilter});

  final List<Claim> claims;
  final String? activeFilter;
}

class ClaimsLoadEmpty extends ClaimsState {
  const ClaimsLoadEmpty({this.activeFilter});

  final String? activeFilter;
}

class ClaimsLoadFailure extends ClaimsState {
  const ClaimsLoadFailure(this.failure);

  final Failure failure;
}

class ClaimsBloc extends Bloc<ClaimsEvent, ClaimsState> {
  ClaimsBloc({required GetMyClaimsUseCase getMyClaimsUseCase})
    : _getMyClaimsUseCase = getMyClaimsUseCase,
      super(const ClaimsInitial()) {
    on<ClaimsRequested>(_onRequested);
    on<ClaimsRefreshed>(_onRefreshed);
  }

  final GetMyClaimsUseCase _getMyClaimsUseCase;

  Future<void> _onRequested(
    ClaimsRequested event,
    Emitter<ClaimsState> emit,
  ) async {
    emit(const ClaimsLoadInProgress());
    await _load(emit, event.statusFilter);
  }

  Future<void> _onRefreshed(
    ClaimsRefreshed event,
    Emitter<ClaimsState> emit,
  ) async {
    final current = state;
    if (current is ClaimsLoadSuccess) {
      emit(ClaimsRefreshInProgress(current.claims));
    } else if (current is ClaimsLoadEmpty) {
      emit(const ClaimsLoadInProgress());
    }
    await _load(emit, event.statusFilter);
  }

  Future<void> _load(Emitter<ClaimsState> emit, String? statusFilter) async {
    final result = statusFilter != null && statusFilter.isNotEmpty
        ? await _getMyClaimsUseCase.byStatus(statusFilter)
        : await _getMyClaimsUseCase(const NoParams());

    result.fold(
      (failure) => emit(ClaimsLoadFailure(failure)),
      (claims) => emit(
        claims.isEmpty
            ? ClaimsLoadEmpty(activeFilter: statusFilter)
            : ClaimsLoadSuccess(claims, activeFilter: statusFilter),
      ),
    );
  }
}
