import 'dart:convert';

import 'package:insurflow/core/network/json_reader.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/features/authentication/data/models/auth_session_model.dart';
import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSession session);

  Future<AuthSession?> readSession();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._tokenStore);

  final TokenStore _tokenStore;

  /// Persists the whole user, not just the token.
  ///
  /// There is no profile endpoint to re-read the user from, so dropping
  /// it here would leave Profile with nothing to show after a restart.
  @override
  Future<void> saveSession(AuthSession session) async {
    await _tokenStore.saveAccessToken(session.accessToken);
    await _tokenStore.saveSession(
      jsonEncode(AuthSessionModel.toJson(session)),
    );
  }

  @override
  Future<AuthSession?> readSession() async {
    final token = await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) return null;

    final stored = await _tokenStore.readSession();
    if (stored != null && stored.isNotEmpty) {
      try {
        final json = JsonReader.asMap(jsonDecode(stored));
        final model = json == null
            ? null
            : AuthSessionModel.fromStoredJson(json);
        if (model != null) return model.toEntity();
      } catch (_) {
        // Corrupt or outdated payload: fall through to the token-only
        // session rather than blocking sign-in.
      }
    }

    // A session saved before user details were persisted still signs the
    // user in; Profile renders its own empty state for the gaps.
    return AuthSession(accessToken: token);
  }

  @override
  Future<void> clear() => _tokenStore.clear();
}
