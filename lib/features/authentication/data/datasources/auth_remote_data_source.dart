import 'package:dio/dio.dart';
import 'package:insurflow/features/authentication/data/models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String organizationCode,
    required String employeeCode,
    required String password,
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

    final session = AuthSessionModel.fromResponse(response.data);
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
}
