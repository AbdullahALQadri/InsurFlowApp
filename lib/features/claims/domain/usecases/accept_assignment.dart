import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

/// Accepts an assignment the officer offered to this adjuster.
///
/// Only a claim awaiting acceptance can be accepted; the backend
/// enforces this too and answers 409 otherwise, so the guard here just
/// avoids a request that is certain to fail.
class AcceptAssignmentUseCase implements UseCase<Claim, Claim> {
  const AcceptAssignmentUseCase(this._repository);

  final ClaimsRepository _repository;

  @override
  Future<Either<Failure, Claim>> call(Claim claim) async {
    if (!claim.status.awaitsAcceptance) {
      return const Left(
        ValidationFailure('Claim is not awaiting acceptance'),
      );
    }
    return _repository.acceptAssignment(claim.id);
  }
}
