/// Secure storage for the signed-in session.
///
/// The access token is read by the Dio interceptor on every request.
/// The session payload holds the user object the login response
/// returned, so Profile can show real values after a restart instead of
/// falling back to placeholders.
abstract class TokenStore {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  /// Serialized session (see `AuthSessionModel.toJson`), or null.
  Future<String?> readSession();

  Future<void> saveSession(String sessionJson);

  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  String? _token;
  String? _session;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;

  @override
  Future<String?> readSession() async => _session;

  @override
  Future<void> saveSession(String sessionJson) async => _session = sessionJson;

  @override
  Future<void> clear() async {
    _token = null;
    _session = null;
  }
}
