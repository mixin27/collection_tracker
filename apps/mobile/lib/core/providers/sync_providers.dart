import 'package:collection_tracker/core/providers/database_providers.dart';
import 'package:collection_tracker/core/sync/dio_sync_backend_client.dart';
import 'package:collection_tracker/core/sync/nest_sync_auth_token_provider.dart';
import 'package:collection_tracker/core/sync/sync_auth_token_provider.dart';
import 'package:collection_tracker/core/sync/sync_backend_client.dart';
import 'package:collection_tracker/core/sync/sync_orchestrator.dart';
import 'package:dio/dio.dart';
import 'package:database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

final syncDaoProvider = Provider<SyncDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.syncDao;
});

final syncApiBaseUrlProvider = Provider<String>((ref) {
  return const String.fromEnvironment('SYNC_API_BASE_URL', defaultValue: '');
});

final syncApiPrefixProvider = Provider<String>((ref) {
  return const String.fromEnvironment(
    'SYNC_API_PREFIX',
    defaultValue: '/api/v1',
  );
});

final syncDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[SyncApi] $obj'),
      ),
    );
  }

  return dio;
});

final syncAuthDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final syncAuthTokenAdapterProvider = Provider<SyncAuthTokenProvider>((ref) {
  final baseUrl = ref.watch(syncApiBaseUrlProvider);
  if (baseUrl.trim().isEmpty) {
    return const NoopSyncAuthTokenProvider();
  }

  final apiPrefix = ref.watch(syncApiPrefixProvider);
  final apiBaseUrl = _joinUrl(baseUrl, apiPrefix);
  final authDio = ref.watch(syncAuthDioProvider);
  final storage = SecureStorageService.instance;

  return NestSyncAuthTokenProvider(
    dio: authDio,
    apiBaseUrl: apiBaseUrl,
    storage: storage,
  );
});

final syncBackendClientProvider = Provider<SyncBackendClient>((ref) {
  final baseUrl = ref.watch(syncApiBaseUrlProvider);
  if (baseUrl.trim().isEmpty) {
    return const NoopSyncBackendClient();
  }

  final dio = ref.watch(syncDioProvider);
  final apiPrefix = ref.watch(syncApiPrefixProvider);
  final tokenProvider = ref.watch(syncAuthTokenAdapterProvider);

  final normalizedBaseUrl = _joinUrl(baseUrl, apiPrefix);

  return DioSyncBackendClient(
    dio: dio,
    baseUrl: normalizedBaseUrl,
    authTokenProvider: tokenProvider,
  );
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final dao = ref.watch(syncDaoProvider);
  final backendClient = ref.watch(syncBackendClientProvider);
  return SyncOrchestrator(syncDao: dao, backendClient: backendClient);
});

final syncOutboxCountProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(syncDaoProvider);
  return dao.watchPendingOperationCount();
});

String _joinUrl(String baseUrl, String prefix) {
  final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final path = prefix.trim();

  if (path.isEmpty || path == '/') {
    return base;
  }

  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$base$normalizedPath';
}
