import 'package:dio/dio.dart';

import '../auth/sync_auth_token_provider.dart';
import '../exceptions/sync_api_exceptions.dart';
import '../models/sync_contract.dart';
import 'sync_backend_client.dart';

class DioSyncBackendClient implements SyncBackendClient {
  DioSyncBackendClient({
    required Dio dio,
    required String baseUrl,
    required SyncAuthTokenProvider authTokenProvider,
    String capabilitiesPath = '/sync/capabilities',
    String syncPath = '/sync',
  }) : _dio = dio,
       _baseUrl = _normalizeBaseUrl(baseUrl),
       _authTokenProvider = authTokenProvider,
       _capabilitiesPath = capabilitiesPath,
       _syncPath = syncPath;

  final Dio _dio;
  final String _baseUrl;
  final SyncAuthTokenProvider _authTokenProvider;
  final String _capabilitiesPath;
  final String _syncPath;

  @override
  Future<SyncCapabilities> getCapabilities() async {
    final response = await _requestWithAuthRetry(
      () => _dio.get<Map<String, dynamic>>('$_baseUrl$_capabilitiesPath'),
      requireAuth: false,
    );
    final data = _asJsonMap(response.data);
    return SyncCapabilities.fromJson(data);
  }

  @override
  Future<SyncResponsePayload> sync(SyncRequestPayload request) async {
    final response = await _requestWithAuthRetry(
      () => _dio.post<Map<String, dynamic>>(
        '$_baseUrl$_syncPath',
        data: request.toJson(),
      ),
      requireAuth: true,
    );
    final data = _asJsonMap(response.data);
    return SyncResponsePayload.fromJson(data);
  }

  Future<Response<T>> _requestWithAuthRetry<T>(
    Future<Response<T>> Function() runRequest, {
    required bool requireAuth,
  }) async {
    var tokenApplied = await _applyAccessToken();

    if (!tokenApplied) {
      final refreshedToken = await _refreshAccessToken(
        requireAuth: requireAuth,
      );
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $refreshedToken';
        tokenApplied = true;
      }
    }

    if (requireAuth && !tokenApplied) {
      throw const SyncAuthRequiredException(
        message: 'Your sync session expired. Please sign in again.',
      );
    }

    try {
      return await runRequest();
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        rethrow;
      }

      final refreshedToken = await _refreshAccessToken(
        requireAuth: requireAuth,
      );
      if (refreshedToken == null || refreshedToken.isEmpty) {
        if (requireAuth) {
          throw const SyncAuthRequiredException(
            message: 'Your sync session expired. Please sign in again.',
          );
        }
        rethrow;
      }

      _dio.options.headers['Authorization'] = 'Bearer $refreshedToken';
      try {
        return await runRequest();
      } on DioException catch (retryError) {
        if (!_isUnauthorized(retryError)) {
          rethrow;
        }
        await _clearAuthState();
        if (requireAuth) {
          throw const SyncAuthRequiredException(
            message: 'Your sync session expired. Please sign in again.',
          );
        }
        rethrow;
      }
    }
  }

  Future<String?> _refreshAccessToken({required bool requireAuth}) async {
    try {
      return await _authTokenProvider.refreshAccessToken();
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        rethrow;
      }
      await _clearAuthState();
      if (requireAuth) {
        throw const SyncAuthRequiredException(
          message: 'Your sync session expired. Please sign in again.',
        );
      }
      return null;
    }
  }

  Future<bool> _applyAccessToken() async {
    final token = await _authTokenProvider.readAccessToken();
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return false;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return true;
  }

  bool _isUnauthorized(DioException error) {
    final status = error.response?.statusCode;
    return status == 401 || status == 403;
  }

  Future<void> _clearAuthState() async {
    _dio.options.headers.remove('Authorization');
    await _authTokenProvider.clearTokens();
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

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
