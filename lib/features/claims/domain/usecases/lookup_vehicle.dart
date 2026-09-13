import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

class LookupVehicleParams {
  const LookupVehicleParams({required this.claimId, required this.plateNumber});

  final String claimId;
  final String plateNumber;
}

class LookupVehicleUseCase
    implements UseCase<VehicleLookupResult, LookupVehicleParams> {
  const LookupVehicleUseCase(this._repository);

  final ClaimsRepository _repository;

  @override
  Future<Either<Failure, VehicleLookupResult>> call(
    LookupVehicleParams params,
  ) {
    return _repository.lookupVehicle(
      claimId: params.claimId,
      plateNumber: params.plateNumber,
    );
  }
}
