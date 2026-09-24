import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/network/failure_mapper.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:insurflow/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
  }) async {
    try {
      final session = await _remote.login(
        organizationCode: organizationCode,
        employeeCode: employeeCode,
        password: password,
      );
      final entity = session.toEntity();
      await _local.saveSession(entity);
      return Right(entity);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() async {
    try {
      return Right(await _local.readSession());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _local.clear();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
