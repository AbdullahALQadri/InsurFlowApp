import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/authentication/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase implements UseCase<AuthSession?, NoParams> {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession?>> call(NoParams params) {
    return _repository.restoreSession();
  }
}
