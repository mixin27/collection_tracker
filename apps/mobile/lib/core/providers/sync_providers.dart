import 'package:collection_tracker/core/providers/database_providers.dart';
import 'package:collection_tracker/core/providers/firebase_runtime_config_provider.dart';
import 'package:collection_tracker/core/sync/sync_orchestrator.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:sync_api/sync_api.dart';

class SyncTransportConfig {
  const SyncTransportConfig({
    required this.featureFlagEnabled,
    required this.baseUrl,
    required this.apiPrefix,
  });

  final bool featureFlagEnabled;
  final String baseUrl;
  final String apiPrefix;

  bool get isApiBaseUrlConfigured => baseUrl.trim().isNotEmpty;

  String get normalizedApiBaseUrl => _joinUrl(baseUrl, apiPrefix);
}

enum SyncReadinessStatus {
  ready,
  disabledByFeatureFlag,
  missingApiConfiguration,
  authenticationRequired,
}

class SyncReadinessState {
  const SyncReadinessState({required this.status, required this.message});

  final SyncReadinessStatus status;
  final String message;

  bool get isReady => status == SyncReadinessStatus.ready;
}

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

final syncFeatureFlagEnabledProvider = Provider<bool>((ref) {
  final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
  return runtimeConfig.syncFeatureEnabled;
});

final syncTransportConfigProvider = Provider<SyncTransportConfig>((ref) {
  final featureFlagEnabled = ref.watch(syncFeatureFlagEnabledProvider);
  final baseUrl = ref.watch(syncApiBaseUrlProvider);
  final apiPrefix = ref.watch(syncApiPrefixProvider);

  return SyncTransportConfig(
    featureFlagEnabled: featureFlagEnabled,
    baseUrl: baseUrl,
    apiPrefix: apiPrefix,
  );
});

final syncOutboxWritesEnabledProvider = Provider<bool>((ref) {
  return ref.watch(syncFeatureFlagEnabledProvider);
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
  final transportConfig = ref.watch(syncTransportConfigProvider);
  if (!transportConfig.isApiBaseUrlConfigured) {
    return const NoopSyncAuthTokenProvider();
  }

  final authDio = ref.watch(syncAuthDioProvider);
  final storage = SecureStorageService.instance;

  return NestSyncAuthTokenProvider(
    dio: authDio,
    apiBaseUrl: transportConfig.normalizedApiBaseUrl,
    storage: storage,
  );
});

final syncBackendClientProvider = Provider<SyncBackendClient>((ref) {
  final transportConfig = ref.watch(syncTransportConfigProvider);

  if (!transportConfig.featureFlagEnabled) {
    return const NoopSyncBackendClient(
      reason: SyncBackendUnavailableReason.featureFlagDisabled,
    );
  }

  if (!transportConfig.isApiBaseUrlConfigured) {
    return const NoopSyncBackendClient(
      reason: SyncBackendUnavailableReason.notConfigured,
      message:
          'Sync backend URL is not configured. Set --dart-define=SYNC_API_BASE_URL.',
    );
  }

  final dio = ref.watch(syncDioProvider);
  final tokenProvider = ref.watch(syncAuthTokenAdapterProvider);

  return DioSyncBackendClient(
    dio: dio,
    baseUrl: transportConfig.normalizedApiBaseUrl,
    authTokenProvider: tokenProvider,
  );
});

final syncAuthSessionProvider = FutureProvider<bool>((ref) async {
  final tokenProvider = ref.watch(syncAuthTokenAdapterProvider);
  return tokenProvider.hasSession();
});

final syncReadinessProvider = FutureProvider<SyncReadinessState>((ref) async {
  final transportConfig = ref.watch(syncTransportConfigProvider);

  if (!transportConfig.featureFlagEnabled) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.disabledByFeatureFlag,
      message: 'Sync is disabled by remote config.',
    );
  }

  if (!transportConfig.isApiBaseUrlConfigured) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.missingApiConfiguration,
      message:
          'Sync API base URL is missing. Configure SYNC_API_BASE_URL to enable sync.',
    );
  }

  final hasSession = await ref.watch(syncAuthSessionProvider.future);
  if (!hasSession) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.authenticationRequired,
      message:
          'Authentication is optional for the app, but required for sync features.',
    );
  }

  return const SyncReadinessState(
    status: SyncReadinessStatus.ready,
    message: 'Sync is ready.',
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
