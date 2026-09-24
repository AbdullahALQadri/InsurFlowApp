/// The signed-in user, exactly as `POST /auth/login` returns them.
///
/// The response carries `data.user` with six fields and nothing else:
/// `id`, `name`, `employeeCode`, `role`, `organizationId`,
/// `organizationName`. There is **no email and no phone number** in any
/// endpoint the mobile app can reach, so neither is modelled here.
///
/// There is also no profile read endpoint (`/users/me`, `/auth/me` and
/// `/profile` are all 404), which makes the login response the single
/// source of truth for the user — hence it is persisted in full.
class AuthSession {
  const AuthSession({
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

  /// `user.id`
  final String? userId;

  /// `user.name`
  final String? displayName;

  /// `user.employeeCode`
  final String? employeeCode;

  /// `user.role`, e.g. `FIELD_ADJUSTER`.
  final String? role;

  /// `user.organizationId`
  final String? organizationId;

  /// `user.organizationName`
  final String? organizationName;

  /// The code typed at login. Not returned by the backend; retained
  /// from the credentials the user entered so the sign-in screen can be
  /// prefilled and Profile can show which organization was used.
  final String? organizationCode;

  /// Name for greetings, falling back to the employee code. Returns
  /// null when the backend gave neither, so callers show their own
  /// empty state rather than a made-up name.
  String? get displayNameOrCode {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final code = employeeCode?.trim();
    return (code != null && code.isNotEmpty) ? code : null;
  }

  /// Callers pass a localized fallback; there is no English default so
  /// an untranslated word cannot leak into the Arabic UI.
  String greetingName({required String fallback}) =>
      displayNameOrCode ?? fallback;

  /// First letter of the display name, for the avatar. Null when there
  /// is no name to take it from.
  String? get initial {
    final source = displayNameOrCode;
    if (source == null || source.isEmpty) return null;
    return source.substring(0, 1).toUpperCase();
  }

  AuthSession copyWith({String? accessToken}) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
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
