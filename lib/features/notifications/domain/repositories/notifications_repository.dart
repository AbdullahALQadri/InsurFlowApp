import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';

abstract class NotificationsRepository {
  /// Registers this device's FCM token against the signed-in user via
  /// `PATCH /users/me/fcm-token`.
  Future<Either<Failure, void>> registerDeviceToken(String fcmToken);
}
