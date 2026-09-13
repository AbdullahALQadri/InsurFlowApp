import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
  });

  Future<Either<Failure, AuthSession?>> restoreSession();

  Future<Either<Failure, void>> logout();
}
