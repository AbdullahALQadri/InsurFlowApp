import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class GetMyClaimsUseCase implements UseCase<List<Claim>, NoParams> {
  const GetMyClaimsUseCase(this._repository);

  final ClaimsRepository _repository;

  @override
  Future<Either<Failure, List<Claim>>> call(NoParams params) {
    return _repository.getMyClaims();
  }

  Future<Either<Failure, List<Claim>>> byStatus(String? status) {
    return _repository.getMyClaims(status: status);
  }
}
