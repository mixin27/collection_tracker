import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseAppCheckService {
  FirebaseAppCheckService._({FirebaseAppCheck? appCheck})
    : _appCheck = appCheck ?? FirebaseAppCheck.instance;

  static FirebaseAppCheckService? _instance;

  static FirebaseAppCheckService get instance {
    _instance ??= FirebaseAppCheckService._();
    return _instance!;
  }

  final FirebaseAppCheck _appCheck;

  bool _initialized = false;
  bool _enabled = false;
  String _providerLabel = 'none';

  bool get isInitialized => _initialized;
  bool get isEnabled => _enabled;
  String get providerLabel => _providerLabel;

  Future<void> initialize({required bool enabled}) async {
    if (Firebase.apps.isEmpty) {
      _initialized = false;
      _enabled = false;
      _providerLabel = 'unavailable';
      return;
    }

    if (!enabled) {
      await _setTokenAutoRefreshEnabled(false);
      _initialized = true;
      _enabled = false;
      _providerLabel = 'disabled';
      return;
    }

    final providerLabel = _resolveProviderLabel();
    if (providerLabel == null) {
      _initialized = true;
      _enabled = false;
      _providerLabel = 'unsupported';
      return;
    }

    try {
      await _appCheck.activate(
        providerAndroid: _androidProvider,
        providerApple: _appleProvider,
      );
      await _setTokenAutoRefreshEnabled(true);

      _initialized = true;
      _enabled = true;
      _providerLabel = providerLabel;
    } catch (error) {
      _initialized = true;
      _enabled = false;
      _providerLabel = 'failed';
      if (kDebugMode) {
        debugPrint('FirebaseAppCheck initialize failed: $error');
      }
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (!_initialized) {
      await initialize(enabled: enabled);
      return;
    }

    if (enabled == _enabled) {
      await _setTokenAutoRefreshEnabled(enabled);
      return;
    }

    if (enabled) {
      await initialize(enabled: true);
      return;
    }

    await _setTokenAutoRefreshEnabled(false);
    _enabled = false;
    _providerLabel = 'disabled';
  }

  Future<void> _setTokenAutoRefreshEnabled(bool enabled) async {
    try {
      await _appCheck.setTokenAutoRefreshEnabled(enabled);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'FirebaseAppCheck setTokenAutoRefreshEnabled($enabled) failed: '
          '$error',
        );
      }
    }
  }

  String? _resolveProviderLabel() {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return kDebugMode ? 'android_debug' : 'android_play_integrity';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return kDebugMode ? 'apple_debug' : 'apple_app_attest_fallback';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  AndroidAppCheckProvider get _androidProvider => kDebugMode
      ? const AndroidDebugProvider()
      : const AndroidPlayIntegrityProvider();

  AppleAppCheckProvider get _appleProvider => kDebugMode
      ? const AppleDebugProvider()
      : const AppleAppAttestWithDeviceCheckFallbackProvider();
}
