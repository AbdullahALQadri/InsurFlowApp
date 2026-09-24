import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/network/failure_mapper.dart';
import 'package:insurflow/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:insurflow/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> registerDeviceToken(String fcmToken) async {
    try {
      await _remote.updateFcmToken(fcmToken);
      return const Right(null);
    } on DioException catch (error) {
      return Left(FailureMapper.fromDio(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
