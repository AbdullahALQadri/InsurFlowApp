import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSession session);

  Future<AuthSession?> readSession();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  Future<void> saveSession(AuthSession session) {
    return _tokenStore.saveAccessToken(session.accessToken);
  }

  @override
  Future<AuthSession?> readSession() async {
    final token = await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) return null;
    return AuthSession(accessToken: token);
  }

  @override
  Future<void> clear() => _tokenStore.clear();
}
