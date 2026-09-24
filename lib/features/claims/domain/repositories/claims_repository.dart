import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

abstract class ClaimsRepository {
  Future<Either<Failure, List<Claim>>> getMyClaims({String? status});

  Future<Either<Failure, Claim>> getClaimDetails(String claimId);

  Future<Either<Failure, Claim>> acceptAssignment(String claimId);

  Future<Either<Failure, Claim>> startClaim(String claimId);

  Future<Either<Failure, Claim>> submitClaim(String claimId);

  Future<Either<Failure, VehicleLookupResult>> lookupVehicle({
    required String claimId,
    required String plateNumber,
  });

  Future<Either<Failure, void>> updateClaimVehicle({
    required String claimId,
    required String vehicleId,
    required String policyId,
    required String customerId,
    required String plateNumber,
  });

  Future<Either<Failure, void>> updateClaimAccident({
    required String claimId,
    required String accidentType,
    required String accidentDate,
    required String accidentTime,
    required String description,
    required String damageDescription,
  });

  Future<Either<Failure, void>> updateClaimLocation({
    required String claimId,
    required double latitude,
    required double longitude,
    required String address,
    DateTime? capturedAt,
  });

  Future<Either<Failure, dynamic>> uploadClaimEvidence({
    required String claimId,
    required String filePath,
    required String imageType,
  });

  Future<Either<Failure, dynamic>> uploadClaimSignature({
    required String claimId,
    required String filePath,
  });

  Future<Either<Failure, Map<String, dynamic>>> getAdjusterStats({
    DateTime? from,
    DateTime? to,
  });
}
