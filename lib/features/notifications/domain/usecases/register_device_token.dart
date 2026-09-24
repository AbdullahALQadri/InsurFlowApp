import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/notifications/domain/repositories/notifications_repository.dart';

class RegisterDeviceTokenUseCase {
  const RegisterDeviceTokenUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Either<Failure, void>> call(String fcmToken) {
    final token = fcmToken.trim();
    // The backend rejects an empty token with 400; there is nothing to
    // register, so do not spend a request on it.
    if (token.isEmpty) return Future.value(const Left(ValidationFailure()));
    return _repository.registerDeviceToken(token);
  }
}
