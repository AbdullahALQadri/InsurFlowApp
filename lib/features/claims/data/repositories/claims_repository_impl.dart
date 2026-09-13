import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/network/failure_mapper.dart';
import 'package:insurflow/features/claims/data/datasources/claims_remote_data_source.dart';
import 'package:insurflow/features/claims/data/mock/claim_details_preview_source.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

class ClaimsRepositoryImpl implements ClaimsRepository {
  ClaimsRepositoryImpl(
    this._remote, {
    ClaimDetailsPreviewSource previewSource = const ClaimDetailsPreviewSource(),
  }) : _previewSource = previewSource;

  final ClaimsRemoteDataSource _remote;
  final ClaimDetailsPreviewSource _previewSource;

  @override
  Future<Either<Failure, List<Claim>>> getMyClaims() async {
    try {
      return Right(await _remote.getMyClaims());
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Claim>> getClaimDetails(String claimId) async {
    try {
      final claim = await _remote.getClaimDetails(claimId);
      return Right(_previewSource.fillMissing(claim));
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Claim>> startClaim(String claimId) async {
    try {
      final claim = await _remote.startClaim(claimId);
      return Right(_previewSource.fillMissing(claim));
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Claim>> submitClaim(String claimId) async {
    try {
      final claim = await _remote.submitClaim(claimId);
      return Right(_previewSource.fillMissing(claim));
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, VehicleLookupResult>> lookupVehicle({
    required String claimId,
    required String plateNumber,
  }) async {
    try {
      return Right(
        await _remote.lookupVehicle(claimId: claimId, plateNumber: plateNumber),
      );
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateClaimVehicle({
    required String claimId,
    required String vehicleId,
    required String policyId,
    required String customerId,
    required String plateNumber,
  }) async {
    try {
      await _remote.updateClaimVehicle(
        claimId: claimId,
        vehicleId: vehicleId,
        policyId: policyId,
        customerId: customerId,
        plateNumber: plateNumber,
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateClaimAccident({
    required String claimId,
    required String accidentType,
    required String accidentDate,
    required String accidentTime,
    required String description,
    required String damageDescription,
  }) async {
    try {
      await _remote.updateClaimAccident(
        claimId: claimId,
        accidentType: accidentType,
        accidentDate: accidentDate,
        accidentTime: accidentTime,
        description: description,
        damageDescription: damageDescription,
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateClaimLocation({
    required String claimId,
    required double latitude,
    required double longitude,
    required String address,
    DateTime? capturedAt,
  }) async {
    try {
      await _remote.updateClaimLocation(
        claimId: claimId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        capturedAt: capturedAt,
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> uploadClaimEvidence({
    required String claimId,
    required String filePath,
    required String imageType,
  }) async {
    try {
      final res = await _remote.uploadClaimEvidence(
        claimId: claimId,
        filePath: filePath,
        imageType: imageType,
      );
      return Right(res);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> uploadClaimSignature({
    required String claimId,
    required String filePath,
  }) async {
    try {
      final res = await _remote.uploadClaimSignature(
        claimId: claimId,
        filePath: filePath,
      );
      return Right(res);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAdjusterStats({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final stats = await _remote.getAdjusterStats(from: from, to: to);
      return Right(stats);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
