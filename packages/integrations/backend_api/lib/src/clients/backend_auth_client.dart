import 'package:dio/dio.dart';

import '../exceptions/backend_api_exception.dart';
import '../models/backend_auth_models.dart';

class BackendAuthClient {
  BackendAuthClient({
    required Dio dio,
    required String apiBaseUrl,
    String authPathPrefix = '/auth',
  }) : _dio = dio,
       _apiBaseUrl = _normalizeBaseUrl(apiBaseUrl),
       _authPathPrefix = authPathPrefix;

  final Dio _dio;
  final String _apiBaseUrl;
  final String _authPathPrefix;

  Future<BackendAuthResponse> register(BackendRegisterRequest request) async {
    final map = await _post(
      path: '$_authPathPrefix/register',
      data: request.toJson(),
    );
    return BackendAuthResponse.fromJson(map);
  }

  Future<BackendAuthResponse> login(BackendLoginRequest request) async {
    final map = await _post(
      path: '$_authPathPrefix/login',
      data: request.toJson(),
    );
    return BackendAuthResponse.fromJson(map);
  }

  Future<BackendTokenPair> refresh(BackendRefreshTokenRequest request) async {
    final map = await _post(
      path: '$_authPathPrefix/refresh',
      data: request.toJson(),
    );
    return BackendTokenPair.fromJson(map);
  }

  Future<void> logout(String accessToken) async {
    await _post(
      path: '$_authPathPrefix/logout',
      data: const <String, dynamic>{},
      accessToken: accessToken,
    );
  }

  Future<void> logoutAll(String accessToken) async {
    await _post(
      path: '$_authPathPrefix/logout-all',
      data: const <String, dynamic>{},
      accessToken: accessToken,
    );
  }

  Future<BackendProfileResponse> me(String accessToken) async {
    final map = await _get(
      path: '$_authPathPrefix/me',
      accessToken: accessToken,
    );
    return BackendProfileResponse.fromJson(map);
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> data,
    String? accessToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl$path',
        data: data,
        options: _authorizedOptions(accessToken),
      );
      return _unwrapToMap(response.data);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    String? accessToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_apiBaseUrl$path',
        options: _authorizedOptions(accessToken),
      );
      return _unwrapToMap(response.data);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Options? _authorizedOptions(String? accessToken) {
    if (accessToken == null || accessToken.trim().isEmpty) {
      return null;
    }

    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }

  BackendApiException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final fallbackMessage = error.message ?? 'Backend API request failed';

    if (responseData is Map) {
      final map = responseData.cast<String, dynamic>();
      final message = _extractMessage(map) ?? fallbackMessage;
      final code = _extractCode(map);
      return BackendApiException(
        message: message,
        statusCode: statusCode,
        code: code,
        raw: map,
      );
    }

    return BackendApiException(
      message: _normalizeMessage(responseData) ?? fallbackMessage,
      statusCode: statusCode,
      raw: responseData,
    );
  }

  String? _extractMessage(Map<String, dynamic> map) {
    final direct =
        _normalizeMessage(map['message']) ?? _normalizeMessage(map['error']);
    if (direct != null) {
      return direct;
    }

    final data = map['data'];
    if (data is Map) {
      return _normalizeMessage(data['message']) ??
          _normalizeMessage(data['error']);
    }

    return null;
  }

  String? _extractCode(Map<String, dynamic> map) {
    final directCode = _normalizeCode(map['code']);
    if (directCode != null) {
      return directCode;
    }

    final data = map['data'];
    if (data is Map) {
      return _normalizeCode(data['code']);
    }

    return null;
  }

  String? _normalizeCode(Object? value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _normalizeMessage(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }

    if (value is List) {
      final parts = value
          .map(_normalizeMessage)
          .whereType<String>()
          .where((text) => text.isNotEmpty)
          .toList();
      if (parts.isEmpty) {
        return null;
      }
      return parts.join(', ');
    }

    if (value is Map) {
      final nested =
          _normalizeMessage(value['message']) ??
          _normalizeMessage(value['error']);
      if (nested != null) {
        return nested;
      }
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  Map<String, dynamic> _unwrapToMap(Object? raw) {
    if (raw is! Map) {
      return const <String, dynamic>{};
    }

    final map = raw.cast<String, dynamic>();
    final nested = map['data'];
    if (nested is Map) {
      return nested.cast<String, dynamic>();
    }

    return map;
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
