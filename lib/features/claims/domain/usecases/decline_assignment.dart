import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class DeclineAssignmentParams {
  const DeclineAssignmentParams({required this.claim, required this.reason});

  final Claim claim;
  final String reason;
}

/// Declines an assignment so the officer can reassign it.
///
/// The backend requires a non-empty `reason` and answers 400 without
/// one, so an empty reason is rejected here rather than spending a
/// request that is certain to fail.
class DeclineAssignmentUseCase {
  const DeclineAssignmentUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, Claim>> call(DeclineAssignmentParams params) {
    final reason = params.reason.trim();
    if (reason.isEmpty) {
      return Future.value(const Left(ValidationFailure('Reason is required')));
    }
    if (!params.claim.status.awaitsAcceptance) {
      return Future.value(
        const Left(ValidationFailure('Claim is not awaiting acceptance')),
      );
    }
    return _repository.declineAssignment(params.claim.id, reason);
  }
}
