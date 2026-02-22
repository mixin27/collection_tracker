import 'package:dio/dio.dart';

import 'sync_auth_token_provider.dart';
import 'sync_backend_client.dart';
import 'sync_contract.dart';

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
    );
    final data = _asJsonMap(response.data);
    return SyncResponsePayload.fromJson(data);
  }

  Future<Response<T>> _requestWithAuthRetry<T>(
    Future<Response<T>> Function() runRequest,
  ) async {
    await _applyAccessToken();

    try {
      return await runRequest();
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        rethrow;
      }

      final refreshedToken = await _authTokenProvider.refreshAccessToken();
      if (refreshedToken == null || refreshedToken.isEmpty) {
        rethrow;
      }

      _dio.options.headers['Authorization'] = 'Bearer $refreshedToken';
      return runRequest();
    }
  }

  Future<void> _applyAccessToken() async {
    final token = await _authTokenProvider.readAccessToken();
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  bool _isUnauthorized(DioException error) {
    return error.response?.statusCode == 401;
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
