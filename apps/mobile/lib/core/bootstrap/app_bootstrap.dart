import 'package:app_analytics/app_analytics.dart';
import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/analytics/analytics_preferences.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:flutter/foundation.dart';
import 'package:storage/storage.dart';

import 'crashlytics_bootstrap.dart';
import 'firebase_bootstrap.dart';
import 'firebase_services_bootstrap.dart';

class AppBootstrapData {
  const AppBootstrapData({
    required this.onboardingComplete,
    required this.firebaseRuntimeConfig,
  });

  final bool onboardingComplete;
  final FirebaseRuntimeConfig firebaseRuntimeConfig;
}

abstract final class AppBootstrap {
  static Future<AppBootstrapData> initialize() async {
    await _initializeLogger();
    await PrefsStorageService.instance.init();
    await FirebaseBootstrap.initialize();
    final firebaseRuntimeConfig = await FirebaseServicesBootstrap.initialize();
    await CrashlyticsBootstrap.initialize(
      collectionEnabled: firebaseRuntimeConfig.crashlyticsCollectionEnabled,
    );
    await _initializeAnalytics(
      analyticsCollectionEnabled:
          firebaseRuntimeConfig.analyticsCollectionEnabled,
    );
    await OperationalTelemetry.trackRuntimeConfigApplied(
      source: 'bootstrap',
      analyticsEnabled: firebaseRuntimeConfig.analyticsCollectionEnabled,
      crashlyticsEnabled: firebaseRuntimeConfig.crashlyticsCollectionEnabled,
      performanceEnabled: firebaseRuntimeConfig.performanceCollectionEnabled,
      appCheckEnabled: firebaseRuntimeConfig.appCheckEnabled,
      fcmEnabled: firebaseRuntimeConfig.fcmEnabled,
      metadataEnabled: firebaseRuntimeConfig.metadataFeatureEnabled,
      backendEnabled: firebaseRuntimeConfig.backendIntegrationEnabled,
      authEnabled: firebaseRuntimeConfig.authFeatureEnabled,
      syncEnabled: firebaseRuntimeConfig.syncFeatureEnabled,
      didActivateChanges: null,
    );

    final onboardingComplete =
        await PrefsStorageService.instance.get<bool>('onboarding_complete') ??
        false;

    Logger.info('All services are initialized!');
    return AppBootstrapData(
      onboardingComplete: onboardingComplete,
      firebaseRuntimeConfig: firebaseRuntimeConfig,
    );
  }

  static Future<void> _initializeLogger() async {
    await Logger.initialize(
      config: LoggerConfig(
        enableConsoleLogging: true,
        enableFileLogging: true,
        enableRemoteLogging: false,
        minLevel: kReleaseMode ? LogLevel.error : LogLevel.debug,
        logFileNamePrefix: 'collection_tracker_log_',
      ),
    );
  }

  static Future<void> _initializeAnalytics({
    required bool analyticsCollectionEnabled,
  }) async {
    final enabled =
        PrefsStorageService.instance.readSync<bool>(
          AnalyticsPreferences.enabledPrefKey,
        ) ??
        true;
    final consentCode = PrefsStorageService.instance.readSync<String>(
      AnalyticsPreferences.consentStatusPrefKey,
    );
    final consentStatus = AnalyticsConsentStatusX.fromCode(consentCode);

    final config = AnalyticsConfig(
      environment: kReleaseMode
          ? AnalyticsEnvironment.production
          : AnalyticsEnvironment.development,
      enableLogging: !kReleaseMode,
      providers: [
        if (!kReleaseMode) ConsoleAnalyticsProvider(prettyPrint: true),
        FirebaseAnalyticsProvider(),
      ],
      middleware: [
        QueueMiddleware(),
        PIIFilterMiddleware(),
        ValidationMiddleware(),
        EnrichmentMiddleware(),
      ],
      autoTrackScreenViews: true,
      requireConsent: true,
    );

    await AnalyticsService.initialize(config);
    await AnalyticsService.instance.setTrackingEnabled(
      enabled && analyticsCollectionEnabled,
    );
    await AnalyticsService.instance.setConsentGranted(
      consentStatus == AnalyticsConsentStatus.granted,
    );
  }
}
