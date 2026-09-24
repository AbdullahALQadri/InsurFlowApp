import 'package:dio/dio.dart';
import 'package:insurflow/features/authentication/data/models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/auth/login',
      data: {
        'organizationCode': organizationCode,
        'employeeCode': employeeCode,
        'password': password,
      },
    );

    // The backend does not echo organizationCode, so carry through the
    // value the user signed in with.
    final session = AuthSessionModel.fromResponse(
      response.data,
      organizationCode: organizationCode,
    );
    if (session == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Login response did not include an access token.',
      );
    }
    return session;
  }

  /// `PUT /auth/change-password`
  ///
  /// Verified against the live backend as a FIELD_ADJUSTER:
  /// * body `{currentPassword, newPassword}`, both required;
  /// * `newPassword` must be at least 8 characters — that is the only
  ///   rule the server enforces;
  /// * 401 `INVALID_CREDENTIALS` when `currentPassword` is wrong;
  /// * 200 on success.
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put<dynamic>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
