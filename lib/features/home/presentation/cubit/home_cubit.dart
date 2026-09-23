import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/usecases/get_adjuster_stats.dart';
import 'package:insurflow/features/claims/domain/usecases/get_my_claims.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  const HomeSuccess({
    required this.claims,
    required this.stats,
    this.activeClaim,
    this.newAssignmentClaim,
    this.isRefreshing = false,
  });

  final List<Claim> claims;
  final Map<String, dynamic> stats;
  final Claim? activeClaim;
  final Claim? newAssignmentClaim;
  final bool isRefreshing;

  int get assignedCount =>
      claims.where((c) => c.status == ClaimStatus.assigned).length;

  int get inProgressCount =>
      claims.where((c) => c.status == ClaimStatus.inProgress).length;

  int get submittedCount =>
      claims.where((c) => c.status == ClaimStatus.submitted).length;

  HomeSuccess copyWith({
    List<Claim>? claims,
    Map<String, dynamic>? stats,
    Claim? activeClaim,
    Claim? newAssignmentClaim,
    bool? isRefreshing,
  }) {
    return HomeSuccess(
      claims: claims ?? this.claims,
      stats: stats ?? this.stats,
      activeClaim: activeClaim ?? this.activeClaim,
      newAssignmentClaim: newAssignmentClaim ?? this.newAssignmentClaim,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeFailure extends HomeState {
  const HomeFailure(this.failure);

  final Failure failure;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetMyClaimsUseCase getMyClaimsUseCase,
    required GetAdjusterStatsUseCase getAdjusterStatsUseCase,
  })  : _getMyClaimsUseCase = getMyClaimsUseCase,
        _getAdjusterStatsUseCase = getAdjusterStatsUseCase,
        super(const HomeInitial());

  final GetMyClaimsUseCase _getMyClaimsUseCase;
  final GetAdjusterStatsUseCase _getAdjusterStatsUseCase;

  Future<void> loadDashboard() async {
    emit(const HomeLoading());
    await _fetchData();
  }

  Future<void> refreshDashboard() async {
    final current = state;
    if (current is HomeSuccess) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final claimsResult = await _getMyClaimsUseCase(const NoParams());
    final statsResult = await _getAdjusterStatsUseCase();

    claimsResult.fold(
      (failure) => emit(HomeFailure(failure)),
      (claims) {
        final stats = statsResult.fold((_) => <String, dynamic>{}, (s) => s);

        Claim? active;
        for (final c in claims) {
          if (c.status == ClaimStatus.inProgress ||
              c.status == ClaimStatus.correctionRequired) {
            active = c;
            break;
          }
        }

        Claim? newAssignment;
        for (final c in claims) {
          if (c.status == ClaimStatus.assigned) {
            newAssignment = c;
            break;
          }
        }

        emit(HomeSuccess(
          claims: claims,
          stats: stats,
          activeClaim: active,
          newAssignmentClaim: newAssignment,
        ));
      },
    );
  }
}
