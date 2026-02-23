import 'package:app_firebase/app_firebase.dart';
import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:flutter/foundation.dart';

import 'crashlytics_bootstrap.dart';

class FirebaseRuntimeConfigRefreshResult {
  const FirebaseRuntimeConfigRefreshResult({
    required this.runtimeConfig,
    required this.status,
    required this.didActivateChanges,
  });

  final FirebaseRuntimeConfig runtimeConfig;
  final FirebaseRemoteConfigStatus status;
  final bool didActivateChanges;
}

abstract final class FirebaseServicesBootstrap {
  static const _analyticsCollectionEnabledKey =
      'app_analytics_collection_enabled';
  static const _crashlyticsCollectionEnabledKey =
      'app_crashlytics_collection_enabled';
  static const _performanceCollectionEnabledKey =
      'app_performance_collection_enabled';
  static const _appCheckEnabledKey = 'app_app_check_enabled';
  static const _fcmEnabledKey = 'app_fcm_enabled';
  static const _metadataFeatureEnabledKey = 'app_metadata_feature_enabled';
  static const _backendIntegrationEnabledKey =
      'app_backend_integration_enabled';
  static const _authFeatureEnabledKey = 'app_auth_feature_enabled';
  static const _syncFeatureEnabledKey = 'app_sync_feature_enabled';

  static Future<FirebaseRuntimeConfig> initialize() async {
    final remoteConfigService = FirebaseRemoteConfigService.instance;

    await remoteConfigService.initialize(
      defaults: {
        _analyticsCollectionEnabledKey: true,
        _crashlyticsCollectionEnabledKey: true,
        _performanceCollectionEnabledKey: true,
        _appCheckEnabledKey: false,
        _fcmEnabledKey: false,
        _metadataFeatureEnabledKey: true,
        _backendIntegrationEnabledKey: false,
        _authFeatureEnabledKey: true,
        _syncFeatureEnabledKey: false,
      },
      minimumFetchInterval: kDebugMode
          ? const Duration(minutes: 5)
          : const Duration(hours: 12),
    );

    final runtimeConfig = _readRuntimeConfig(remoteConfigService);

    await FirebaseAppCheckService.instance.initialize(
      enabled: runtimeConfig.appCheckEnabled,
    );
    await FirebaseMessagingService.instance.initialize(
      enabled: runtimeConfig.fcmEnabled,
    );
    await FirebasePerformanceService.instance.initialize(
      enabled: runtimeConfig.performanceCollectionEnabled,
    );

    Logger.info(
      'Firebase services initialized (analytics: ${runtimeConfig.analyticsCollectionEnabled}, '
      'crashlytics: ${runtimeConfig.crashlyticsCollectionEnabled}, '
      'performance: ${runtimeConfig.performanceCollectionEnabled}, '
      'appCheck: ${runtimeConfig.appCheckEnabled}, '
      'fcm: ${runtimeConfig.fcmEnabled}, '
      'metadata: ${runtimeConfig.metadataFeatureEnabled}, '
      'backend: ${runtimeConfig.backendIntegrationEnabled}, '
      'auth: ${runtimeConfig.authFeatureEnabled}, '
      'sync: ${runtimeConfig.syncFeatureEnabled}).',
    );

    return runtimeConfig;
  }

  static Future<FirebaseRuntimeConfigRefreshResult> refreshRuntimeConfig({
    bool forceFetch = false,
  }) async {
    final remoteConfigService = FirebaseRemoteConfigService.instance;
    if (!remoteConfigService.isInitialized) {
      final runtimeConfig = await initialize();
      return FirebaseRuntimeConfigRefreshResult(
        runtimeConfig: runtimeConfig,
        status: remoteConfigService.status,
        didActivateChanges: false,
      );
    }

    final didActivateChanges = forceFetch
        ? await remoteConfigService.refreshForced()
        : await remoteConfigService.refresh();
    final runtimeConfig = _readRuntimeConfig(remoteConfigService);

    await FirebaseAppCheckService.instance.setEnabled(
      runtimeConfig.appCheckEnabled,
    );
    await FirebaseMessagingService.instance.setEnabled(
      runtimeConfig.fcmEnabled,
    );
    await FirebasePerformanceService.instance.setCollectionEnabled(
      runtimeConfig.performanceCollectionEnabled,
    );
    await CrashlyticsBootstrap.setCollectionEnabled(
      collectionEnabled: runtimeConfig.crashlyticsCollectionEnabled,
    );

    Logger.info(
      'Firebase runtime config refreshed (changed: $didActivateChanges, '
      'analytics: ${runtimeConfig.analyticsCollectionEnabled}, '
      'crashlytics: ${runtimeConfig.crashlyticsCollectionEnabled}, '
      'performance: ${runtimeConfig.performanceCollectionEnabled}, '
      'appCheck: ${runtimeConfig.appCheckEnabled}, '
      'fcm: ${runtimeConfig.fcmEnabled}, '
      'metadata: ${runtimeConfig.metadataFeatureEnabled}, '
      'backend: ${runtimeConfig.backendIntegrationEnabled}, '
      'auth: ${runtimeConfig.authFeatureEnabled}, '
      'sync: ${runtimeConfig.syncFeatureEnabled}).',
    );
    await OperationalTelemetry.trackRuntimeConfigApplied(
      source: forceFetch ? 'manual_refresh' : 'auto_refresh',
      analyticsEnabled: runtimeConfig.analyticsCollectionEnabled,
      crashlyticsEnabled: runtimeConfig.crashlyticsCollectionEnabled,
      performanceEnabled: runtimeConfig.performanceCollectionEnabled,
      appCheckEnabled: runtimeConfig.appCheckEnabled,
      fcmEnabled: runtimeConfig.fcmEnabled,
      metadataEnabled: runtimeConfig.metadataFeatureEnabled,
      backendEnabled: runtimeConfig.backendIntegrationEnabled,
      authEnabled: runtimeConfig.authFeatureEnabled,
      syncEnabled: runtimeConfig.syncFeatureEnabled,
      didActivateChanges: didActivateChanges,
    );

    return FirebaseRuntimeConfigRefreshResult(
      runtimeConfig: runtimeConfig,
      status: remoteConfigService.status,
      didActivateChanges: didActivateChanges,
    );
  }

  static FirebaseRuntimeConfig _readRuntimeConfig(
    FirebaseRemoteConfigService remoteConfigService,
  ) {
    return FirebaseRuntimeConfig(
      analyticsCollectionEnabled: remoteConfigService.getBool(
        _analyticsCollectionEnabledKey,
        fallback: true,
      ),
      crashlyticsCollectionEnabled: remoteConfigService.getBool(
        _crashlyticsCollectionEnabledKey,
        fallback: true,
      ),
      performanceCollectionEnabled: remoteConfigService.getBool(
        _performanceCollectionEnabledKey,
        fallback: true,
      ),
      appCheckEnabled: remoteConfigService.getBool(
        _appCheckEnabledKey,
        fallback: false,
      ),
      fcmEnabled: remoteConfigService.getBool(_fcmEnabledKey, fallback: false),
      metadataFeatureEnabled: remoteConfigService.getBool(
        _metadataFeatureEnabledKey,
        fallback: true,
      ),
      backendIntegrationEnabled: remoteConfigService.getBool(
        _backendIntegrationEnabledKey,
        fallback: false,
      ),
      authFeatureEnabled: remoteConfigService.getBool(
        _authFeatureEnabledKey,
        fallback: true,
      ),
      syncFeatureEnabled: remoteConfigService.getBool(
        _syncFeatureEnabledKey,
        fallback: false,
      ),
    );
  }
}
