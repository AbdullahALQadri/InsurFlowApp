import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';

/// Maps `POST /auth/login`.
///
/// Verified shape:
/// ```
/// { success, message, data: {
///     accessToken: "<jwt>",
///     user: { id, name, employeeCode, role,
///             organizationId, organizationName }
/// }}
/// ```
///
/// Keys are read exactly — no alias guessing — and the same shape is
/// reused for local persistence so a restored session is identical to a
/// freshly logged-in one.
class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    this.userId,
    this.displayName,
    this.employeeCode,
    this.role,
    this.organizationId,
    this.organizationName,
    this.organizationCode,
  });

  final String accessToken;
  final String? userId;
  final String? displayName;
  final String? employeeCode;
  final String? role;
  final String? organizationId;
  final String? organizationName;
  final String? organizationCode;

  /// [organizationCode] is what the user typed at login; the backend
  /// does not echo it back, so it is passed in rather than parsed.
  static AuthSessionModel? fromResponse(
    dynamic body, {
    String? organizationCode,
  }) {
    final root = JsonReader.asMap(body);
    if (root == null) return null;

    final data = JsonReader.nested(root, ['data']) ?? root;
    final token = JsonReader.string(data, ['accessToken']);
    if (token == null) return null;

    final user = JsonReader.nested(data, ['user']) ?? const {};

    return AuthSessionModel(
      accessToken: token,
      userId: JsonReader.string(user, ['id']),
      displayName: JsonReader.string(user, ['name']),
      employeeCode: JsonReader.string(user, ['employeeCode']),
      role: JsonReader.string(user, ['role']),
      organizationId: JsonReader.string(user, ['organizationId']),
      organizationName: JsonReader.string(user, ['organizationName']),
      organizationCode: organizationCode?.trim(),
    );
  }

  /// Rebuilds a session persisted by [toJson].
  static AuthSessionModel? fromStoredJson(Map<String, dynamic> json) {
    final token = JsonReader.string(json, ['accessToken']);
    if (token == null) return null;

    return AuthSessionModel(
      accessToken: token,
      userId: JsonReader.string(json, ['userId']),
      displayName: JsonReader.string(json, ['displayName']),
      employeeCode: JsonReader.string(json, ['employeeCode']),
      role: JsonReader.string(json, ['role']),
      organizationId: JsonReader.string(json, ['organizationId']),
      organizationName: JsonReader.string(json, ['organizationName']),
      organizationCode: JsonReader.string(json, ['organizationCode']),
    );
  }

  static Map<String, dynamic> toJson(AuthSession session) {
    return {
      'accessToken': session.accessToken,
      if (session.userId != null) 'userId': session.userId,
      if (session.displayName != null) 'displayName': session.displayName,
      if (session.employeeCode != null) 'employeeCode': session.employeeCode,
      if (session.role != null) 'role': session.role,
      if (session.organizationId != null)
        'organizationId': session.organizationId,
      if (session.organizationName != null)
        'organizationName': session.organizationName,
      if (session.organizationCode != null)
        'organizationCode': session.organizationCode,
    };
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      userId: userId,
      displayName: displayName,
      employeeCode: employeeCode,
      role: role,
      organizationId: organizationId,
      organizationName: organizationName,
      organizationCode: organizationCode,
    );
  }
}
