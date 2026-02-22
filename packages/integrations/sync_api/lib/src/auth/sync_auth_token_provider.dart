import 'package:storage/storage.dart';

abstract class SyncAuthTokenProvider {
  Future<bool> hasSession();
  Future<String?> readAccessToken();
  Future<String?> refreshAccessToken();
  Future<void> clearTokens();
}

class NoopSyncAuthTokenProvider implements SyncAuthTokenProvider {
  const NoopSyncAuthTokenProvider();

  @override
  Future<void> clearTokens() async {}

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> refreshAccessToken() async => null;
}

class SecureStorageSyncAuthTokenProvider implements SyncAuthTokenProvider {
  SecureStorageSyncAuthTokenProvider({
    required SecureStorageService storage,
    this.accessTokenKey = 'sync_access_token',
    this.refreshTokenKey = 'sync_refresh_token',
  }) : _storage = storage;

  final SecureStorageService _storage;
  final String accessTokenKey;
  final String refreshTokenKey;

  @override
  Future<String?> readAccessToken() {
    return _storage.get<String>(accessTokenKey);
  }

  @override
  Future<String?> refreshAccessToken() async {
    // Placeholder for future auth exchange flow.
    // For now we return currently stored access token (if any).
    return _storage.get<String>(accessTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(accessTokenKey);
    await _storage.delete(refreshTokenKey);
  }

  @override
  Future<bool> hasSession() async {
    final accessToken = await _storage.get<String>(accessTokenKey);
    if (accessToken != null && accessToken.isNotEmpty) {
      return true;
    }

    final refreshToken = await _storage.get<String>(refreshTokenKey);
    return refreshToken != null && refreshToken.isNotEmpty;
  }
}
