import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class UpdateClaimAccidentUseCase {
  const UpdateClaimAccidentUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, void>> call({
    required String claimId,
    required String accidentType,
    required String accidentDate,
    required String accidentTime,
    required String description,
    required String damageDescription,
  }) {
    return _repository.updateClaimAccident(
      claimId: claimId,
      accidentType: accidentType,
      accidentDate: accidentDate,
      accidentTime: accidentTime,
      description: description,
      damageDescription: damageDescription,
    );
  }
}
