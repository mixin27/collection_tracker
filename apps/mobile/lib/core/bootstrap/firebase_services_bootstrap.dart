import 'package:app_firebase/app_firebase.dart';
import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
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

  static Future<FirebaseRuntimeConfig> initialize() async {
    final remoteConfigService = FirebaseRemoteConfigService.instance;

    await remoteConfigService.initialize(
      defaults: {
        _analyticsCollectionEnabledKey: true,
        _crashlyticsCollectionEnabledKey: true,
        _performanceCollectionEnabledKey: true,
      },
      minimumFetchInterval: kDebugMode
          ? const Duration(minutes: 5)
          : const Duration(hours: 12),
    );

    final runtimeConfig = _readRuntimeConfig(remoteConfigService);

    await FirebasePerformanceService.instance.initialize(
      enabled: runtimeConfig.performanceCollectionEnabled,
    );

    Logger.info(
      'Firebase services initialized (analytics: ${runtimeConfig.analyticsCollectionEnabled}, '
      'crashlytics: ${runtimeConfig.crashlyticsCollectionEnabled}, '
      'performance: ${runtimeConfig.performanceCollectionEnabled}).',
    );

    return runtimeConfig;
  }

  static Future<FirebaseRuntimeConfigRefreshResult>
  refreshRuntimeConfig() async {
    final remoteConfigService = FirebaseRemoteConfigService.instance;
    if (!remoteConfigService.isInitialized) {
      final runtimeConfig = await initialize();
      return FirebaseRuntimeConfigRefreshResult(
        runtimeConfig: runtimeConfig,
        status: remoteConfigService.status,
        didActivateChanges: false,
      );
    }

    final didActivateChanges = await remoteConfigService.refresh();
    final runtimeConfig = _readRuntimeConfig(remoteConfigService);

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
      'performance: ${runtimeConfig.performanceCollectionEnabled}).',
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
    );
  }
}
