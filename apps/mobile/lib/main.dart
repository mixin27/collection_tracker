import 'package:app_analytics/app_analytics.dart';
import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:storage/storage.dart';
import 'package:collection_tracker/core/observers/riverpod_logger.dart';
import 'package:storage/storage.dart';

import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with configuration
  await Logger.initialize(
    config: LoggerConfig(
      enableConsoleLogging: true,
      enableFileLogging: true,
      enableRemoteLogging: false,
      minLevel: kReleaseMode ? LogLevel.error : LogLevel.debug,
      logFileNamePrefix: 'collection_tracker_log_',
    ),
  );

  // Initialize PrefsStorageService
  await PrefsStorageService.instance.init();

  // Check onboarding status
  final prefs = PrefsStorageService.instance;
  final onboardingComplete =
      await prefs.get<bool>('onboarding_complete') ?? false;

  // Configure analytics
  final config = AnalyticsConfig(
    environment: AnalyticsEnvironment.development,
    enableLogging: true,
    providers: [
      ConsoleAnalyticsProvider(prettyPrint: true),
      // GoogleAnalytics4Provider(
      //   measurementId: 'G-XXXXXXXXXX', // Replace with valid ID
      //   apiSecret: 'YOUR_API_SECRET', // Optional, for Measurement Protocol
      // ),
    ],
    middleware: [
      // ConsentMiddleware(), // Check consent first
      QueueMiddleware(), // Queue offline events
      PIIFilterMiddleware(), // Remove PII
      ValidationMiddleware(), // Validate events
      EnrichmentMiddleware(), // Add common properties
    ],
    autoTrackScreenViews: true,
    requireConsent: false,
  );

  // Initialize
  await AnalyticsService.initialize(config);

  Logger.info("All services are initialized!");

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompleteProvider.overrideWith((ref) => onboardingComplete),
      ],
      observers: [RiverpodLogger()],
      child: const CollectionTrackerApp(),
    ),
  );
}
