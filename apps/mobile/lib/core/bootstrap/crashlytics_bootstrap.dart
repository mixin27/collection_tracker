import 'package:app_logger/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract final class CrashlyticsBootstrap {
  static Future<void> initialize() async {
    const enableInDebug = bool.fromEnvironment(
      'ENABLE_CRASHLYTICS_IN_DEBUG',
      defaultValue: false,
    );
    final crashlyticsSupported = !kIsWeb && Firebase.apps.isNotEmpty;
    final crashlyticsEnabled =
        crashlyticsSupported && (!kDebugMode || enableInDebug);

    if (!crashlyticsSupported) {
      Logger.info(
        'Crashlytics skipped: unsupported platform or Firebase unavailable.',
      );
      return;
    }

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      crashlyticsEnabled,
    );

    final previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      previousFlutterErrorHandler?.call(details);
      if (crashlyticsEnabled) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        Logger.error(
          'Flutter framework error captured (Crashlytics disabled).',
          details.exception,
          details.stack,
        );
      }
    };

    final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      if (crashlyticsEnabled) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'PlatformDispatcher uncaught error',
        );
      } else {
        Logger.error(
          'Uncaught platform error captured (Crashlytics disabled).',
          error,
          stackTrace,
        );
      }
      previousPlatformErrorHandler?.call(error, stackTrace);
      return true;
    };

    Logger.info(
      'Crashlytics initialized (enabled: $crashlyticsEnabled, debug: $kDebugMode, debugOverride: $enableInDebug).',
    );
  }
}
