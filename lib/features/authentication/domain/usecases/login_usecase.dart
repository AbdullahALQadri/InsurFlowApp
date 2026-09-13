import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginParams {
  const LoginParams({
    required this.organizationCode,
    required this.employeeCode,
    required this.password,
  });

  final String organizationCode;
  final String employeeCode;
  final String password;
}

class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) {
    return _repository.login(
      organizationCode: params.organizationCode,
      employeeCode: params.employeeCode,
      password: params.password,
    );
  }
}
