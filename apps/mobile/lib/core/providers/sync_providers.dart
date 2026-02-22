import 'package:collection_tracker/core/providers/database_providers.dart';
import 'package:collection_tracker/core/providers/auth_session_providers.dart';
import 'package:collection_tracker/core/providers/backend_api_providers.dart';
import 'package:collection_tracker/core/sync/sync_outbox_bootstrapper.dart';
import 'package:collection_tracker/core/sync/sync_orchestrator.dart';
import 'package:collection_tracker/core/sync/sync_server_changes_applier.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_api/sync_api.dart';

class SyncTransportConfig {
  const SyncTransportConfig({
    required this.backendFeatureEnabled,
    required this.syncFeatureEnabled,
    required this.baseUrl,
    required this.apiPrefix,
  });

  final bool backendFeatureEnabled;
  final bool syncFeatureEnabled;
  final String baseUrl;
  final String apiPrefix;

  bool get featureFlagEnabled => backendFeatureEnabled && syncFeatureEnabled;

  bool get isApiBaseUrlConfigured => baseUrl.trim().isNotEmpty;

  String get normalizedApiBaseUrl => _joinUrl(baseUrl, apiPrefix);
}

enum SyncReadinessStatus {
  ready,
  disabledByFeatureFlag,
  missingApiConfiguration,
  checkingAuthentication,
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

final syncFeatureFlagEnabledProvider = Provider<bool>((ref) {
  final backendFeatureEnabled = ref.watch(
    backendIntegrationFeatureFlagProvider,
  );
  final syncFeatureEnabled = ref.watch(backendSyncFeatureFlagProvider);
  return backendFeatureEnabled && syncFeatureEnabled;
});

final syncTransportConfigProvider = Provider<SyncTransportConfig>((ref) {
  final backendFeatureEnabled = ref.watch(
    backendIntegrationFeatureFlagProvider,
  );
  final syncFeatureEnabled = ref.watch(backendSyncFeatureFlagProvider);
  final baseUrl = ref.watch(backendApiBaseUrlProvider);
  final apiPrefix = ref.watch(backendApiPrefixProvider);

  return SyncTransportConfig(
    backendFeatureEnabled: backendFeatureEnabled,
    syncFeatureEnabled: syncFeatureEnabled,
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
  final sessionStore = ref.watch(authSessionStoreProvider);

  return NestSyncAuthTokenProvider(
    dio: authDio,
    apiBaseUrl: transportConfig.normalizedApiBaseUrl,
    sessionStore: sessionStore,
  );
});

final syncBackendClientProvider = Provider<SyncBackendClient>((ref) {
  final transportConfig = ref.watch(syncTransportConfigProvider);

  if (!transportConfig.backendFeatureEnabled) {
    return const NoopSyncBackendClient(
      reason: SyncBackendUnavailableReason.featureFlagDisabled,
      message: 'Backend integration is disabled by feature flags.',
    );
  }

  if (!transportConfig.syncFeatureEnabled) {
    return const NoopSyncBackendClient(
      reason: SyncBackendUnavailableReason.featureFlagDisabled,
      message: 'Sync is disabled by feature flags.',
    );
  }

  if (!transportConfig.isApiBaseUrlConfigured) {
    return const NoopSyncBackendClient(
      reason: SyncBackendUnavailableReason.notConfigured,
      message: 'Backend API base URL is not configured.',
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

final syncReadinessProvider = Provider<SyncReadinessState>((ref) {
  final transportConfig = ref.watch(syncTransportConfigProvider);

  if (!transportConfig.backendFeatureEnabled) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.disabledByFeatureFlag,
      message: 'Backend integration is disabled by feature flags.',
    );
  }

  if (!transportConfig.syncFeatureEnabled) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.disabledByFeatureFlag,
      message: 'Sync is disabled by feature flags.',
    );
  }

  if (!transportConfig.isApiBaseUrlConfigured) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.missingApiConfiguration,
      message:
          'Sync API base URL is missing. Configure BACKEND_API_BASE_URL or set base URL override in settings.',
    );
  }

  final sessionAsync = ref.watch(authSessionProvider);
  if (sessionAsync.isLoading) {
    return const SyncReadinessState(
      status: SyncReadinessStatus.checkingAuthentication,
      message: 'Checking authentication session...',
    );
  }

  final session = sessionAsync.value;
  if (session == null || !session.isAuthenticated) {
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
  final serverChangesApplier = ref.watch(syncServerChangesApplierProvider);
  return SyncOrchestrator(
    syncDao: dao,
    backendClient: backendClient,
    serverChangesApplier: serverChangesApplier,
  );
});

final syncServerChangesApplierProvider = Provider<SyncServerChangesApplier>((
  ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return SyncServerChangesApplier(database: database);
});

final syncOutboxBootstrapperProvider = Provider<SyncOutboxBootstrapper>((ref) {
  final syncDao = ref.watch(syncDaoProvider);
  final collectionDao = ref.watch(collectionDaoProvider);
  final itemDao = ref.watch(itemDaoProvider);
  return SyncOutboxBootstrapper(
    syncDao: syncDao,
    collectionDao: collectionDao,
    itemDao: itemDao,
  );
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
