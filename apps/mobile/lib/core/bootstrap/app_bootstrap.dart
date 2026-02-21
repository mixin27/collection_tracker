import 'package:app_analytics/app_analytics.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:storage/storage.dart';

import 'crashlytics_bootstrap.dart';
import 'firebase_bootstrap.dart';

class AppBootstrapData {
  const AppBootstrapData({required this.onboardingComplete});

  final bool onboardingComplete;
}

abstract final class AppBootstrap {
  static Future<AppBootstrapData> initialize() async {
    await _initializeLogger();
    await PrefsStorageService.instance.init();
    await FirebaseBootstrap.initialize();
    await CrashlyticsBootstrap.initialize();
    await _initializeAnalytics();

    final onboardingComplete =
        await PrefsStorageService.instance.get<bool>('onboarding_complete') ??
        false;

    Logger.info('All services are initialized!');
    return AppBootstrapData(onboardingComplete: onboardingComplete);
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

  static Future<void> _initializeAnalytics() async {
    final config = AnalyticsConfig(
      environment: AnalyticsEnvironment.development,
      enableLogging: true,
      providers: [
        ConsoleAnalyticsProvider(prettyPrint: true),
        FirebaseAnalyticsProvider(),
      ],
      middleware: [
        QueueMiddleware(),
        PIIFilterMiddleware(),
        ValidationMiddleware(),
        EnrichmentMiddleware(),
      ],
      autoTrackScreenViews: true,
      requireConsent: false,
    );

    await AnalyticsService.initialize(config);
  }
}
