import 'package:dio/dio.dart';

abstract class NotificationsRemoteDataSource {
  Future<void> updateFcmToken(String fcmToken);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// `PATCH /users/me/fcm-token`
  ///
  /// Verified against the live backend:
  /// * body `{"fcmToken": "<non-empty string>"}` — required, must be a
  ///   string, and the schema is strict (any other field returns 400
  ///   `"<field>" is not allowed`).
  /// * 200 -> `{success, message: "Device token updated successfully",
  ///   data: {id, fcmToken}}`
  /// * 401 without a bearer token.
  ///
  /// This endpoint is NOT in the Postman collection; it was found by
  /// probing the deployed API.
  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await _dio.patch<dynamic>(
      '/users/me/fcm-token',
      data: {'fcmToken': fcmToken},
    );
  }
}
