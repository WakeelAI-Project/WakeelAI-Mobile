/// Single source of truth for every key used with [FlutterSecureStorage] (or
/// any future secure-storage-backed store), so keys can't drift out of sync
/// between reads and writes.
abstract final class StorageKeys {
  static const accessToken = 'auth_access_token';
  static const refreshToken = 'auth_refresh_token';
}
