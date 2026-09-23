import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class UpdateClaimLocationUseCase {
  const UpdateClaimLocationUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, void>> call({
    required String claimId,
    required double latitude,
    required double longitude,
    required String address,
    DateTime? capturedAt,
  }) {
    return _repository.updateClaimLocation(
      claimId: claimId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      capturedAt: capturedAt,
    );
  }
}
