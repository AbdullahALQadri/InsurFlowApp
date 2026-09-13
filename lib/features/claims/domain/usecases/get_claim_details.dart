import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class GetClaimDetailsUseCase implements UseCase<Claim, String> {
  const GetClaimDetailsUseCase(this._repository);

  final ClaimsRepository _repository;

  @override
  Future<Either<Failure, Claim>> call(String claimId) {
    return _repository.getClaimDetails(claimId);
  }
}
