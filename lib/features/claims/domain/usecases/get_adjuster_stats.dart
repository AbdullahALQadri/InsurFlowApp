import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class GetAdjusterStatsUseCase {
  const GetAdjusterStatsUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, Map<String, dynamic>>> call({
    DateTime? from,
    DateTime? to,
  }) {
    return _repository.getAdjusterStats(from: from, to: to);
  }
}
