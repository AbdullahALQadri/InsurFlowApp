import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class StartClaimUseCase implements UseCase<Claim, Claim> {
  const StartClaimUseCase(this._repository);

  final ClaimsRepository _repository;

  @override
  Future<Either<Failure, Claim>> call(Claim claim) async {
    if (!claim.status.canResumeInspection) {
      return const Left(
        ValidationFailure('Cannot start claim in current status'),
      );
    }
    return _repository.startClaim(claim.id);
  }
}
