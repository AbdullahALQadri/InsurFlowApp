abstract class TokenStore {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> saveAccessToken(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
