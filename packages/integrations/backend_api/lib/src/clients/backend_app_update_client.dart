import 'package:dio/dio.dart';

import '../exceptions/backend_api_exception.dart';
import '../models/backend_app_update_models.dart';

class BackendAppUpdateClient {
  BackendAppUpdateClient({
    required Dio dio,
    required String apiBaseUrl,
    String appUpdatePath = '/app-update/check',
  }) : _dio = dio,
       _apiBaseUrl = _normalizeBaseUrl(apiBaseUrl),
       _appUpdatePath = appUpdatePath;

  final Dio _dio;
  final String _apiBaseUrl;
  final String _appUpdatePath;

  Future<BackendAppUpdateCheckResponse> check(
    BackendAppUpdateCheckRequest request,
  ) async {
    final map = await _post(path: _appUpdatePath, data: request.toJson());
    return BackendAppUpdateCheckResponse.fromJson(map);
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_apiBaseUrl$path',
        data: data,
      );
      return _unwrapToMap(response.data);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
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
