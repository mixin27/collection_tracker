import 'package:auth_session/auth_session.dart';
import 'package:dio/dio.dart';

import 'sync_auth_token_provider.dart';

class NestSyncAuthTokenProvider implements SyncAuthTokenProvider {
  NestSyncAuthTokenProvider({
    required Dio dio,
    required String apiBaseUrl,
    required AuthSessionStore sessionStore,
    this.refreshPath = '/auth/refresh',
  }) : _dio = dio,
       _apiBaseUrl = _normalizeBaseUrl(apiBaseUrl),
       _sessionStore = sessionStore;

  final Dio _dio;
  final String _apiBaseUrl;
  final AuthSessionStore _sessionStore;

  final String refreshPath;

  @override
  Future<String?> readAccessToken() async {
    final session = await _sessionStore.readSession();
    if (!session.hasAccessToken) {
      return null;
    }
    return session.accessToken;
  }

  @override
  Future<String?> refreshAccessToken() async {
    final session = await _sessionStore.readSession();
    final refreshToken = session.refreshToken;
    final deviceId = session.deviceId;

    if (refreshToken == null ||
        refreshToken.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty ||
        _apiBaseUrl.isEmpty) {
      return null;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '$_apiBaseUrl$refreshPath',
      data: <String, dynamic>{
        'refreshToken': refreshToken,
        'deviceId': deviceId,
      },
    );

    final data = _asJsonMap(response.data);
    final newAccessToken = data['accessToken'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;

    if (newAccessToken == null || newAccessToken.isEmpty) {
      return null;
    }

    await _sessionStore.saveSession(
      session.copyWith(
        status: AuthSessionStatus.signedIn,
        accessToken: newAccessToken,
        refreshToken: (newRefreshToken != null && newRefreshToken.isNotEmpty)
            ? newRefreshToken
            : refreshToken,
        deviceId: deviceId,
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    return newAccessToken;
  }

  @override
  Future<void> clearTokens() {
    return _sessionStore.clearSession();
  }

  @override
  Future<bool> hasSession() async {
    final session = await _sessionStore.readSession();
    return session.isAuthenticated;
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static Map<String, dynamic> _asJsonMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.cast<String, dynamic>();
    }
    return const <String, dynamic>{};
  }
}
