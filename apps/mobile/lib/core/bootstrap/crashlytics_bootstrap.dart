import 'package:app_logger/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract final class CrashlyticsBootstrap {
  static bool _handlersRegistered = false;
  static bool _collectionEnabled = false;

  static const _enableInDebug = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS_IN_DEBUG',
    defaultValue: false,
  );

  static Future<void> initialize({required bool collectionEnabled}) async {
    if (!_isSupported) {
      Logger.info(
        'Crashlytics skipped: unsupported platform or Firebase unavailable.',
      );
      return;
    }

    await setCollectionEnabled(collectionEnabled: collectionEnabled);

    if (_handlersRegistered) {
      Logger.info(
        'Crashlytics initialized (enabled: $_collectionEnabled, debug: $kDebugMode, debugOverride: $_enableInDebug).',
      );
      return;
    }

    final previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      previousFlutterErrorHandler?.call(details);
      if (_collectionEnabled) {
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
      if (_collectionEnabled) {
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

    _handlersRegistered = true;
    Logger.info(
      'Crashlytics initialized (enabled: $_collectionEnabled, debug: $kDebugMode, debugOverride: $_enableInDebug).',
    );
  }

  static Future<void> setCollectionEnabled({
    required bool collectionEnabled,
  }) async {
    if (!_isSupported) {
      _collectionEnabled = false;
      return;
    }

    _collectionEnabled = _resolveEnabled(collectionEnabled);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      _collectionEnabled,
    );

    Logger.info(
      'Crashlytics collection updated: $_collectionEnabled '
      '(remote flag: $collectionEnabled, debug: $kDebugMode, debugOverride: $_enableInDebug).',
    );
  }

  static bool get _isSupported => !kIsWeb && Firebase.apps.isNotEmpty;

  static bool _resolveEnabled(bool remoteCollectionEnabled) {
    return remoteCollectionEnabled && (!kDebugMode || _enableInDebug);
  }
}
