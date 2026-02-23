import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../models/firebase_remote_config_status.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfigService? _instance;

  static FirebaseRemoteConfigService get instance {
    _instance ??= FirebaseRemoteConfigService._();
    return _instance!;
  }

  final FirebaseRemoteConfig _remoteConfig;

  bool _initialized = false;
  Duration _fetchTimeout = const Duration(seconds: 10);
  Duration _minimumFetchInterval = const Duration(hours: 12);

  bool get isInitialized => _initialized;

  FirebaseRemoteConfigStatus get status => FirebaseRemoteConfigStatus(
    isInitialized: _initialized,
    lastFetchTime: _initialized ? _remoteConfig.lastFetchTime : null,
    lastFetchStatus: _initialized ? _remoteConfig.lastFetchStatus : null,
  );

  Future<void> initialize({
    Map<String, Object> defaults = const {},
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(hours: 12),
    bool fetchAndActivate = true,
  }) async {
    if (_initialized || Firebase.apps.isEmpty) {
      return;
    }

    try {
      _fetchTimeout = fetchTimeout;
      _minimumFetchInterval = minimumFetchInterval;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: fetchTimeout,
          minimumFetchInterval: minimumFetchInterval,
        ),
      );

      if (defaults.isNotEmpty) {
        await _remoteConfig.setDefaults(defaults);
      }

      if (fetchAndActivate) {
        try {
          await _remoteConfig.fetchAndActivate();
        } catch (error) {
          if (kDebugMode) {
            debugPrint(
              'FirebaseRemoteConfig fetchAndActivate failed during initialize: $error',
            );
          }
        }
      }

      _initialized = true;
    } catch (error) {
      _initialized = false;
      if (kDebugMode) {
        debugPrint('FirebaseRemoteConfig initialize failed: $error');
      }
    }
  }

  Future<bool> refresh() async {
    if (!_initialized) {
      return false;
    }

    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseRemoteConfig refresh failed: $error');
      }
      return false;
    }
  }

  Future<bool> refreshForced() async {
    if (!_initialized) {
      return false;
    }

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          minimumFetchInterval: Duration.zero,
        ),
      );

      return await _remoteConfig.fetchAndActivate();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebaseRemoteConfig forced refresh failed: $error');
      }
      return false;
    } finally {
      try {
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: _fetchTimeout,
            minimumFetchInterval: _minimumFetchInterval,
          ),
        );
      } catch (_) {
        // Ignore reset failure.
      }
    }
  }

  bool getBool(String key, {bool fallback = false}) {
    if (!_initialized) {
      return fallback;
    }

    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return fallback;
    }
  }

  int getInt(String key, {int fallback = 0}) {
    if (!_initialized) {
      return fallback;
    }

    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      return fallback;
    }
  }

  double getDouble(String key, {double fallback = 0}) {
    if (!_initialized) {
      return fallback;
    }

    try {
      return _remoteConfig.getDouble(key);
    } catch (_) {
      return fallback;
    }
  }

  String getString(String key, {String fallback = ''}) {
    if (!_initialized) {
      return fallback;
    }

    try {
      return _remoteConfig.getString(key);
    } catch (_) {
      return fallback;
    }
  }

  Map<String, RemoteConfigValue> getAll() {
    if (!_initialized) {
      return {};
    }

    return _remoteConfig.getAll();
  }
}
