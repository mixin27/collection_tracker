import 'package:auth_session/auth_session.dart';
import 'package:backend_api/backend_api.dart';
import 'package:collection_tracker/core/auth/backend_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:uuid/uuid.dart';

import 'auth_session_providers.dart';
import 'firebase_runtime_config_provider.dart';

class BackendApiReadiness {
  const BackendApiReadiness({required this.enabled, required this.message});

  final bool enabled;
  final String message;
}

final backendApiBaseUrlOverrideProvider =
    NotifierProvider<BackendApiBaseUrlOverrideController, String>(
      BackendApiBaseUrlOverrideController.new,
    );

class BackendApiBaseUrlOverrideController extends Notifier<String> {
  static const _key = 'backend_api_base_url_override';

  @override
  String build() {
    final saved = PrefsStorageService.instance.readSync<String>(_key);
    return (saved ?? '').trim();
  }

  Future<void> setBaseUrl(String baseUrl) async {
    final normalized = baseUrl.trim();
    await PrefsStorageService.instance.save<String>(_key, normalized);
    state = normalized;
  }

  Future<void> clear() async {
    await PrefsStorageService.instance.delete(_key);
    state = '';
  }
}

final backendIntegrationFeatureFlagProvider = Provider<bool>((ref) {
  final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
  const envOverride = bool.fromEnvironment(
    'BACKEND_INTEGRATION_ENABLED',
    defaultValue: false,
  );
  return runtimeConfig.backendIntegrationEnabled || envOverride;
});

final backendSyncFeatureFlagProvider = Provider<bool>((ref) {
  final runtimeConfig = ref.watch(firebaseRuntimeConfigProvider);
  const envOverride = bool.fromEnvironment(
    'BACKEND_SYNC_ENABLED',
    defaultValue: false,
  );
  return runtimeConfig.syncFeatureEnabled || envOverride;
});

final backendApiPrefixProvider = Provider<String>((ref) {
  final raw = const String.fromEnvironment(
    'BACKEND_API_PREFIX',
    defaultValue: '/api/v1',
  );

  if (raw.trim().isEmpty) {
    return '/api/v1';
  }

  return raw.startsWith('/') ? raw : '/$raw';
});

final backendApiBaseUrlProvider = Provider<String>((ref) {
  final override = ref.watch(backendApiBaseUrlOverrideProvider).trim();
  if (override.isNotEmpty) {
    return _normalizeBaseUrl(override);
  }

  final env = const String.fromEnvironment('BACKEND_API_BASE_URL');
  if (env.trim().isNotEmpty) {
    return _normalizeBaseUrl(env);
  }

  if (!kDebugMode) {
    return '';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:4000';
  }

  return 'http://localhost:4000';
});

final backendApiRootProvider = Provider<String>((ref) {
  final baseUrl = ref.watch(backendApiBaseUrlProvider);
  if (baseUrl.isEmpty) {
    return '';
  }

  final prefix = ref.watch(backendApiPrefixProvider);
  return '$baseUrl$prefix';
});

final backendApiReadinessProvider = Provider<BackendApiReadiness>((ref) {
  final integrationEnabled = ref.watch(backendIntegrationFeatureFlagProvider);
  if (!integrationEnabled) {
    return const BackendApiReadiness(
      enabled: false,
      message: 'Backend integration is disabled by feature flags.',
    );
  }

  final baseUrl = ref.watch(backendApiBaseUrlProvider);
  if (baseUrl.isEmpty) {
    return const BackendApiReadiness(
      enabled: false,
      message: 'Backend API URL is missing.',
    );
  }

  return const BackendApiReadiness(
    enabled: true,
    message: 'Backend integration is enabled.',
  );
});

final backendApiDioProvider = Provider<Dio>((ref) {
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
        logPrint: (obj) => debugPrint('[BackendApi] $obj'),
      ),
    );
  }

  return dio;
});

final backendAuthClientProvider = Provider<BackendAuthClient?>((ref) {
  final readiness = ref.watch(backendApiReadinessProvider);
  if (!readiness.enabled) {
    return null;
  }

  final root = ref.watch(backendApiRootProvider);
  if (root.isEmpty) {
    return null;
  }

  return BackendAuthClient(
    dio: ref.watch(backendApiDioProvider),
    apiBaseUrl: root,
  );
});

final backendDeviceIdProvider = FutureProvider<String>((ref) async {
  final storage = SecureStorageService.instance;

  const currentKey = 'backend_device_id';
  const legacyKey = 'sync_device_id';

  String? deviceId = await storage.get<String>(currentKey);
  if (deviceId == null || deviceId.trim().isEmpty) {
    deviceId = await storage.get<String>(legacyKey);
  }

  if (deviceId == null || deviceId.trim().isEmpty) {
    deviceId = const Uuid().v4();
  }

  await storage.save<String>(currentKey, deviceId);
  await storage.save<String>(legacyKey, deviceId);

  return deviceId;
});

final backendAuthServiceProvider = Provider<BackendAuthService?>((ref) {
  final client = ref.watch(backendAuthClientProvider);
  if (client == null) {
    return null;
  }

  final sessionStore = ref.watch(authSessionStoreProvider);

  return BackendAuthService(
    client: client,
    sessionStore: sessionStore,
    resolveDeviceId: () => ref.read(backendDeviceIdProvider.future),
    appVersion: const String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    ),
  );
});

final backendSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return ref.watch(authSessionStoreProvider);
});

String _normalizeBaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  return trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
