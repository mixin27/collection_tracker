import 'dart:async';
import 'dart:convert';

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
  Future<String?>? _inFlightRefresh;

  final String refreshPath;

  @override
  Future<String?> readAccessToken() async {
    final session = await _sessionStore.readSession();
    final token = session.accessToken?.trim();
    if (token == null || token.isEmpty) {
      return null;
    }
    if (_isJwtExpired(token, tolerance: const Duration(seconds: 30))) {
      return null;
    }
    return token;
  }

  @override
  Future<String?> refreshAccessToken() {
    final pending = _inFlightRefresh;
    if (pending != null) {
      return pending;
    }

    final refreshFuture = _refreshAccessTokenInternal();
    _inFlightRefresh = refreshFuture;
    refreshFuture.whenComplete(() {
      if (identical(_inFlightRefresh, refreshFuture)) {
        _inFlightRefresh = null;
      }
    });
    return refreshFuture;
  }

  Future<String?> _refreshAccessTokenInternal() async {
    final session = await _sessionStore.readSession();
    final refreshToken = session.refreshToken;
    final deviceId = _resolveDeviceId(session);

    if (refreshToken == null ||
        refreshToken.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty ||
        _apiBaseUrl.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl$refreshPath',
        data: <String, dynamic>{
          'refreshToken': refreshToken,
          'deviceId': deviceId,
        },
      );

      final data = _unwrapResponseData(response.data);
      final nestedTokens = _asJsonMap(data['tokens']);
      final newAccessToken = _firstNonEmptyString(<Object?>[
        data['accessToken'],
        data['access_token'],
        data['token'],
        nestedTokens['accessToken'],
        nestedTokens['access_token'],
        nestedTokens['token'],
      ]);
      final newRefreshToken = _firstNonEmptyString(<Object?>[
        data['refreshToken'],
        data['refresh_token'],
        nestedTokens['refreshToken'],
        nestedTokens['refresh_token'],
      ]);
      final expiresAt = _parseExpiresAt(data);

      if (newAccessToken == null) {
        return null;
      }

      await _sessionStore.saveSession(
        session.copyWith(
          status: AuthSessionStatus.signedIn,
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
          deviceId: deviceId,
          expiresAt: expiresAt ?? session.expiresAt,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      return newAccessToken;
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        rethrow;
      }

      // If another request already refreshed in parallel, trust the latest session.
      final latestSession = await _sessionStore.readSession();
      final latestToken = latestSession.accessToken?.trim();
      final previousToken = session.accessToken?.trim();
      if (latestToken != null &&
          latestToken.isNotEmpty &&
          latestToken != previousToken) {
        return latestToken;
      }

      await _sessionStore.clearSession();
      return null;
    }
  }

  @override
  Future<void> clearTokens() {
    return _sessionStore.clearSession();
  }

  @override
  Future<bool> hasSession() async {
    final session = await _sessionStore.readSession();
    final accessToken = session.accessToken?.trim();
    final hasUsableAccessToken =
        accessToken != null &&
        accessToken.isNotEmpty &&
        !_isJwtExpired(accessToken);
    return session.status == AuthSessionStatus.signedIn &&
        (session.canRefresh || hasUsableAccessToken);
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

  static Map<String, dynamic> _unwrapResponseData(Object? raw) {
    final map = _asJsonMap(raw);
    final nested = _asJsonMap(map['data']);
    return nested.isEmpty ? map : nested;
  }

  static bool _isUnauthorized(DioException error) {
    final status = error.response?.statusCode;
    return status == 401 || status == 403;
  }

  static String? _firstNonEmptyString(Iterable<Object?> values) {
    for (final value in values) {
      if (value is! String) {
        continue;
      }
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? _resolveDeviceId(AuthSession session) {
    final direct = _firstNonEmptyString(<Object?>[session.deviceId]);
    if (direct != null) {
      return direct;
    }

    final refreshClaims = _decodeJwtClaims(session.refreshToken);
    final refreshClaimDeviceId = _firstNonEmptyString(<Object?>[
      refreshClaims['deviceId'],
      refreshClaims['device_id'],
    ]);
    if (refreshClaimDeviceId != null) {
      return refreshClaimDeviceId;
    }

    final accessClaims = _decodeJwtClaims(session.accessToken);
    return _firstNonEmptyString(<Object?>[
      accessClaims['deviceId'],
      accessClaims['device_id'],
    ]);
  }

  DateTime? _parseExpiresAt(Map<String, dynamic> payload) {
    final sessionMap = _asJsonMap(payload['session']);
    final source = _firstNonEmptyString(<Object?>[
      payload['expiresAt'],
      payload['expires_at'],
      sessionMap['expiresAt'],
      sessionMap['expires_at'],
    ]);
    if (source == null) {
      return null;
    }
    return DateTime.tryParse(source)?.toUtc();
  }

  static bool _isJwtExpired(
    String? token, {
    Duration tolerance = Duration.zero,
  }) {
    final claims = _decodeJwtClaims(token);
    final rawExp = claims['exp'];
    if (rawExp == null) {
      return false;
    }

    final expSeconds = rawExp is int
        ? rawExp
        : (rawExp is num
              ? rawExp.toInt()
              : (rawExp is String ? int.tryParse(rawExp) : null));
    if (expSeconds == null) {
      return false;
    }

    final expiryMillis = expSeconds * 1000;
    final thresholdMillis = DateTime.now()
        .toUtc()
        .add(tolerance)
        .millisecondsSinceEpoch;
    return thresholdMillis >= expiryMillis;
  }

  static Map<String, dynamic> _decodeJwtClaims(String? token) {
    if (token == null) {
      return const <String, dynamic>{};
    }
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return const <String, dynamic>{};
    }

    final parts = trimmed.split('.');
    if (parts.length != 3) {
      return const <String, dynamic>{};
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final raw = jsonDecode(decoded);
      return _asJsonMap(raw);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
}
