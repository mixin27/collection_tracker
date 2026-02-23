import 'package:auth_session/auth_session.dart';

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

class AuthSessionSyncAuthTokenProvider implements SyncAuthTokenProvider {
  AuthSessionSyncAuthTokenProvider({required AuthSessionStore sessionStore})
    : _sessionStore = sessionStore;

  final AuthSessionStore _sessionStore;

  @override
  Future<String?> readAccessToken() async {
    final session = await _sessionStore.readSession();
    return session.hasAccessToken ? session.accessToken : null;
  }

  @override
  Future<String?> refreshAccessToken() {
    // Refresh is adapter-specific; this fallback only returns currently stored token.
    return readAccessToken();
  }

  @override
  Future<void> clearTokens() async {
    await _sessionStore.clearSession();
  }

  @override
  Future<bool> hasSession() async {
    final session = await _sessionStore.readSession();
    return session.isAuthenticated;
  }
}
