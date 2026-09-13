import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    this.displayName,
    this.employeeCode,
    this.organizationCode,
    this.role,
  });

  final String accessToken;
  final String? displayName;
  final String? employeeCode;
  final String? organizationCode;
  final String? role;

  /// The collection does not include a login success example. Tokens are
  /// read from the first present key among common JWT response fields.
  static AuthSessionModel? fromResponse(dynamic body) {
    final root = JsonReader.asMap(body);
    if (root == null) return null;

    final token = _tokenFrom(root);
    if (token == null) return null;

    final user = JsonReader.nested(root, ['user', 'employee', 'profile']) ??
        JsonReader.nested(
          JsonReader.nested(root, ['data', 'result', 'payload']) ?? root,
          ['user', 'employee', 'profile'],
        );

    final source = user ?? JsonReader.object(root) ?? root;

    return AuthSessionModel(
      accessToken: token,
      displayName: JsonReader.string(source, [
        'name',
        'fullName',
        'displayName',
        'employeeName',
      ]),
      employeeCode: JsonReader.string(source, ['employeeCode', 'code']),
      organizationCode: JsonReader.string(source, [
        'organizationCode',
        'orgCode',
      ]),
      role: JsonReader.string(source, ['role', 'userRole']),
    );
  }

  static String? _tokenFrom(Map<String, dynamic> json) {
    final direct = JsonReader.string(json, [
      'accessToken',
      'token',
      'access_token',
      'jwt',
    ]);
    if (direct != null) return direct;

    for (final key in ['data', 'result', 'payload']) {
      final nested = JsonReader.asMap(json[key]);
      if (nested == null) continue;
      final nestedToken = JsonReader.string(nested, [
        'accessToken',
        'token',
        'access_token',
        'jwt',
      ]);
      if (nestedToken != null) return nestedToken;
    }
    return null;
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      displayName: displayName,
      employeeCode: employeeCode,
      organizationCode: organizationCode,
      role: role,
    );
  }
}
