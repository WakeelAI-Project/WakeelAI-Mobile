import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access + refresh JWT pair across app restarts (API doc
/// §2.1: refresh token is 7-day lived and must live in secure storage on
/// mobile). Abstract so tests can supply an in-memory fake instead of
/// touching the platform secure-storage channel.
abstract class TokenStorage {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> clearTokens();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage(const FlutterSecureStorage());
});
