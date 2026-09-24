import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:insurflow/core/network/token_store.dart';

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'insurflow.access_token';
  static const _sessionKey = 'insurflow.session';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> readSession() => _storage.read(key: _sessionKey);

  @override
  Future<void> saveSession(String sessionJson) =>
      _storage.write(key: _sessionKey, value: sessionJson);

  @override
  Future<void> clear() async {
    // Sign-out must leave nothing behind for the next user of the device.
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _sessionKey);
  }
}
