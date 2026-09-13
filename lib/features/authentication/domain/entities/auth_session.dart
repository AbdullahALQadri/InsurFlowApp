class AuthSession {
  const AuthSession({
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

  String greetingName({String fallback = 'Adjuster'}) {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final code = employeeCode?.trim();
    if (code != null && code.isNotEmpty) return code;
    return fallback;
  }
}
