import 'package:dio/dio.dart';
import 'package:storage/storage.dart';

import 'sync_auth_token_provider.dart';

class NestSyncAuthTokenProvider implements SyncAuthTokenProvider {
  NestSyncAuthTokenProvider({
    required Dio dio,
    required String apiBaseUrl,
    required SecureStorageService storage,
    this.refreshPath = '/auth/refresh',
    this.accessTokenKey = 'sync_access_token',
    this.refreshTokenKey = 'sync_refresh_token',
    this.deviceIdKey = 'sync_device_id',
  }) : _dio = dio,
       _apiBaseUrl = _normalizeBaseUrl(apiBaseUrl),
       _storage = storage;

  final Dio _dio;
  final String _apiBaseUrl;
  final SecureStorageService _storage;

  final String refreshPath;
  final String accessTokenKey;
  final String refreshTokenKey;
  final String deviceIdKey;

  @override
  Future<String?> readAccessToken() {
    return _storage.get<String>(accessTokenKey);
  }

  @override
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.get<String>(refreshTokenKey);
    final deviceId = await _storage.get<String>(deviceIdKey);

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

    await _storage.save<String>(accessTokenKey, newAccessToken);
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _storage.save<String>(refreshTokenKey, newRefreshToken);
    }

    return newAccessToken;
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
    final deviceId = await _storage.get<String>(deviceIdKey);
    return refreshToken != null &&
        refreshToken.isNotEmpty &&
        deviceId != null &&
        deviceId.isNotEmpty;
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
