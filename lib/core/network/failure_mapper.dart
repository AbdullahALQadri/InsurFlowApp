import 'package:dio/dio.dart';
import 'package:insurflow/core/error/failures.dart';

class FailureMapper {
  FailureMapper._();

  static Failure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return fromStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return const UnexpectedFailure();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return const NetworkFailure();
        }
        return const UnexpectedFailure();
    }
  }

  static Failure fromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return const ForbiddenFailure();
      case 404:
        return const NotFoundFailure();
      case 400:
      case 409:
      case 422:
        return const ValidationFailure();
      default:
        return const ServerFailure();
    }
  }
}
