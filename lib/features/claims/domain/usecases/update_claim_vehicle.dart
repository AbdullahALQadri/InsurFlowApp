import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class UpdateClaimVehicleUseCase {
  const UpdateClaimVehicleUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, void>> call({
    required String claimId,
    required String vehicleId,
    required String policyId,
    required String customerId,
    required String plateNumber,
  }) {
    return _repository.updateClaimVehicle(
      claimId: claimId,
      vehicleId: vehicleId,
      policyId: policyId,
      customerId: customerId,
      plateNumber: plateNumber,
    );
  }
}
