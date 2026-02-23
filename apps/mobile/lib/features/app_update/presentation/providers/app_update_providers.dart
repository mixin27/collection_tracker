import 'package:app_firebase/app_firebase.dart';
import 'package:backend_api/backend_api.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/app_update_models.dart';

final appUpdateFeatureFlagProvider = Provider<bool>((ref) {
  ref.watch(firebaseRuntimeConfigProvider);
  return FirebaseRemoteConfigService.instance.getBool(
    _keyFeatureEnabled,
    fallback: true,
  );
});

final appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateState>(
      AppUpdateController.new,
    );

final appUpdateSummaryProvider = Provider<String>((ref) {
  final enabled = ref.watch(appUpdateFeatureFlagProvider);
  if (!enabled) {
    return 'Disabled by runtime config';
  }

  final state = ref.watch(appUpdateControllerProvider);
  if (state.isChecking) {
    return 'Checking for updates...';
  }

  final result = state.lastResult;
  if (result == null) {
    return 'Tap to check';
  }

  return switch (result.status) {
    AppUpdateStatus.upToDate => 'App is up to date',
    AppUpdateStatus.updateAvailable =>
      'Update available${_suffixVersion(result.latestVersion)}',
    AppUpdateStatus.updateRequired =>
      'Update required${_suffixVersion(result.minSupportedVersion ?? result.latestVersion)}',
    AppUpdateStatus.deferred => 'Update deferred',
    AppUpdateStatus.disabled => 'Disabled by runtime config',
    AppUpdateStatus.notConfigured => 'Not configured',
    AppUpdateStatus.error => 'Update check failed',
  };
});

class AppUpdateController extends Notifier<AppUpdateState> {
  static const _lastCheckAtKey = 'app_update_last_check_at_v1';
  static const _snoozeUntilKey = 'app_update_snooze_until_v1';

  @override
  AppUpdateState build() {
    final lastCheck = _readDateSync(_lastCheckAtKey);
    return AppUpdateState(lastCheckAt: lastCheck);
  }

  Future<AppUpdateResult> checkNow({String trigger = 'manual'}) {
    return _runCheck(userInitiated: true, trigger: trigger);
  }

  Future<AppUpdateResult?> checkIfDue({String trigger = 'auto'}) async {
    if (!ref.read(onboardingCompleteProvider)) {
      return null;
    }

    final featureEnabled = ref.read(appUpdateFeatureFlagProvider);
    if (!featureEnabled) {
      final disabled = AppUpdateResult(
        status: AppUpdateStatus.disabled,
        source: AppUpdateSource.none,
        checkedAt: DateTime.now().toUtc(),
        currentVersion: ref.read(appSemanticVersionProvider) ?? '0.0.0',
      );
      state = state.copyWith(lastResult: disabled, clearErrorMessage: true);
      return disabled;
    }

    final current = state.lastResult;
    if (current != null && current.isForceUpdate) {
      return current;
    }

    final remoteConfig = FirebaseRemoteConfigService.instance;
    final intervalHours = _clampHours(
      remoteConfig.getInt(_keyCheckIntervalHours, fallback: 12),
      fallback: 12,
      min: 1,
      max: 168,
    );
    final now = DateTime.now().toUtc();
    final lastCheck = _readDateSync(_lastCheckAtKey);
    if (lastCheck != null &&
        now.difference(lastCheck) < Duration(hours: intervalHours)) {
      return null;
    }

    return _runCheck(userInitiated: false, trigger: trigger);
  }

  Future<void> snoozeCurrent({int? hours}) async {
    final result = state.lastResult;
    if (result == null || !result.canSnooze) {
      return;
    }

    final effectiveHours = _clampHours(
      hours ?? result.snoozeHours,
      fallback: 24,
      min: 1,
      max: 720,
    );
    final until = DateTime.now().toUtc().add(Duration(hours: effectiveHours));
    await PrefsStorageService.instance.save<String>(
      _snoozeUntilKey,
      until.toIso8601String(),
    );

    state = state.copyWith(
      lastResult: result.copyWith(status: AppUpdateStatus.deferred),
      clearErrorMessage: true,
    );
  }

  Future<void> clearSnooze() async {
    await PrefsStorageService.instance.delete(_snoozeUntilKey);
    final current = state.lastResult;
    if (current == null) {
      return;
    }

    if (current.status == AppUpdateStatus.deferred) {
      state = state.copyWith(
        lastResult: current.copyWith(status: AppUpdateStatus.updateAvailable),
        clearErrorMessage: true,
      );
    }
  }

  Future<bool> openStore(AppUpdateResult result) async {
    final storeUrl = result.storeUrl?.trim();
    if (storeUrl == null || storeUrl.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(storeUrl);
    if (uri == null) {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<AppUpdateResult> _runCheck({
    required bool userInitiated,
    required String trigger,
  }) async {
    final currentVersion = ref.read(appSemanticVersionProvider) ?? '0.0.0';
    final currentBuildNumber = ref
        .read(appPackageInfoProvider)
        .asData
        ?.value
        .buildNumber
        .trim();
    final locale = ref.read(localeSettingsProvider).code;

    state = state.copyWith(isChecking: true, clearErrorMessage: true);

    final now = DateTime.now().toUtc();

    try {
      final featureEnabled = ref.read(appUpdateFeatureFlagProvider);
      if (!featureEnabled) {
        final disabled = AppUpdateResult(
          status: AppUpdateStatus.disabled,
          source: AppUpdateSource.none,
          checkedAt: now,
          currentVersion: currentVersion,
        );
        await _persistLastCheck(now);
        state = state.copyWith(
          isChecking: false,
          lastResult: disabled,
          lastCheckAt: now,
          clearErrorMessage: true,
        );
        return disabled;
      }

      AppUpdateResult? fromBackend;
      try {
        fromBackend = await _checkFromBackend(
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
          localeCode: locale,
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[AppUpdate] Backend check failed: $error');
        }
      }

      AppUpdateResult result;
      if (fromBackend != null) {
        result = fromBackend;
      } else {
        result = _checkFromRemoteConfig(
          currentVersion: currentVersion,
          checkedAt: now,
        );
      }

      final snoozeUntil = _readDateSync(_snoozeUntilKey);
      if (!userInitiated &&
          result.status == AppUpdateStatus.updateAvailable &&
          snoozeUntil != null &&
          snoozeUntil.isAfter(now)) {
        result = result.copyWith(status: AppUpdateStatus.deferred);
      }

      if (result.isForceUpdate) {
        await clearSnooze();
      }

      await _persistLastCheck(now);

      state = state.copyWith(
        isChecking: false,
        lastResult: result.copyWith(checkedAt: now),
        lastCheckAt: now,
        clearErrorMessage: true,
      );

      return state.lastResult!;
    } catch (error) {
      final fallback = AppUpdateResult(
        status: AppUpdateStatus.error,
        source: AppUpdateSource.none,
        checkedAt: now,
        currentVersion: currentVersion,
        errorMessage: error.toString(),
      );
      await _persistLastCheck(now);
      state = state.copyWith(
        isChecking: false,
        lastResult: fallback,
        lastCheckAt: now,
        errorMessage: error.toString(),
      );
      return fallback;
    } finally {
      if (kDebugMode) {
        debugPrint('[AppUpdate] Check completed (trigger: $trigger)');
      }
    }
  }

  Future<AppUpdateResult?> _checkFromBackend({
    required String currentVersion,
    required String? currentBuildNumber,
    required String localeCode,
  }) async {
    final remoteConfig = FirebaseRemoteConfigService.instance;
    final useBackend = remoteConfig.getBool(_keyUseBackend, fallback: true);
    if (!useBackend) {
      return null;
    }

    final client = ref.read(backendAppUpdateClientProvider);
    if (client == null) {
      return null;
    }

    final response = await client.check(
      BackendAppUpdateCheckRequest(
        platform: _platformCode,
        currentVersion: currentVersion,
        buildNumber: currentBuildNumber,
        channel: _releaseChannel,
        locale: localeCode,
      ),
    );

    final fallbackStoreUrl = _storeUrlFromRemoteConfig(remoteConfig);
    final resolvedStoreUrl =
        _normalizeText(response.storeUrl) ?? fallbackStoreUrl;
    final resolvedTitle =
        _normalizeText(response.title) ??
        remoteConfig.getString(_keyTitle, fallback: '');
    final resolvedMessage =
        _normalizeText(response.message) ??
        remoteConfig.getString(_keyMessage, fallback: '');
    final resolvedSnoozeHours = _clampHours(
      response.snoozeHours ??
          remoteConfig.getInt(_keySnoozeHours, fallback: 24),
      fallback: 24,
      min: 1,
      max: 720,
    );

    var status = _statusFromBackend(response.status);

    if (_isLowerVersion(currentVersion, response.minSupportedVersion)) {
      status = AppUpdateStatus.updateRequired;
    } else if (_isLowerVersion(currentVersion, response.latestVersion)) {
      status ??= AppUpdateStatus.updateAvailable;
    } else {
      status ??= AppUpdateStatus.upToDate;
    }

    return AppUpdateResult(
      status: status,
      source: AppUpdateSource.backend,
      checkedAt: DateTime.now().toUtc(),
      currentVersion: currentVersion,
      latestVersion: _normalizeText(response.latestVersion),
      minSupportedVersion: _normalizeText(response.minSupportedVersion),
      title: _normalizeText(resolvedTitle),
      message: _normalizeText(resolvedMessage),
      storeUrl: _normalizeText(resolvedStoreUrl),
      snoozeHours: resolvedSnoozeHours,
    );
  }

  AppUpdateResult _checkFromRemoteConfig({
    required String currentVersion,
    required DateTime checkedAt,
  }) {
    final remoteConfig = FirebaseRemoteConfigService.instance;
    final latestVersionKey = _latestVersionKeyForPlatform();
    final minSupportedVersionKey = _minSupportedVersionKeyForPlatform();
    final latestVersion = _normalizeText(
      remoteConfig.getString(latestVersionKey, fallback: ''),
    );
    final minSupportedVersion = _normalizeText(
      remoteConfig.getString(minSupportedVersionKey, fallback: ''),
    );
    final forceMode = remoteConfig.getBool(_keyForceMode, fallback: false);
    final title = _normalizeText(
      remoteConfig.getString(_keyTitle, fallback: ''),
    );
    final message = _normalizeText(
      remoteConfig.getString(_keyMessage, fallback: ''),
    );
    final storeUrl = _storeUrlFromRemoteConfig(remoteConfig);
    final snoozeHours = _clampHours(
      remoteConfig.getInt(_keySnoozeHours, fallback: 24),
      fallback: 24,
      min: 1,
      max: 720,
    );

    if (latestVersion == null && minSupportedVersion == null) {
      return AppUpdateResult(
        status: AppUpdateStatus.notConfigured,
        source: AppUpdateSource.remoteConfig,
        checkedAt: checkedAt,
        currentVersion: currentVersion,
        title: title,
        message: message,
        storeUrl: storeUrl,
        snoozeHours: snoozeHours,
      );
    }

    if (_isLowerVersion(currentVersion, minSupportedVersion)) {
      return AppUpdateResult(
        status: AppUpdateStatus.updateRequired,
        source: AppUpdateSource.remoteConfig,
        checkedAt: checkedAt,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minSupportedVersion: minSupportedVersion,
        title: title,
        message: message,
        storeUrl: storeUrl,
        snoozeHours: snoozeHours,
      );
    }

    if (_isLowerVersion(currentVersion, latestVersion)) {
      return AppUpdateResult(
        status: forceMode
            ? AppUpdateStatus.updateRequired
            : AppUpdateStatus.updateAvailable,
        source: AppUpdateSource.remoteConfig,
        checkedAt: checkedAt,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minSupportedVersion: minSupportedVersion,
        title: title,
        message: message,
        storeUrl: storeUrl,
        snoozeHours: snoozeHours,
      );
    }

    return AppUpdateResult(
      status: AppUpdateStatus.upToDate,
      source: AppUpdateSource.remoteConfig,
      checkedAt: checkedAt,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      minSupportedVersion: minSupportedVersion,
      title: title,
      message: message,
      storeUrl: storeUrl,
      snoozeHours: snoozeHours,
    );
  }

  Future<void> _persistLastCheck(DateTime now) async {
    await PrefsStorageService.instance.save<String>(
      _lastCheckAtKey,
      now.toIso8601String(),
    );
  }

  DateTime? _readDateSync(String key) {
    final value = PrefsStorageService.instance.readSync<String>(key);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}

String _suffixVersion(String? version) {
  final normalized = _normalizeText(version);
  if (normalized == null) {
    return '';
  }
  return ' ($normalized)';
}

String? _normalizeText(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

bool _isLowerVersion(String currentVersion, String? targetVersion) {
  final normalizedTarget = _normalizeText(targetVersion);
  if (normalizedTarget == null) {
    return false;
  }
  return _compareVersion(currentVersion, normalizedTarget) < 0;
}

int _compareVersion(String left, String right) {
  final leftParts = _parseVersionParts(left);
  final rightParts = _parseVersionParts(right);
  final maxLength = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var i = 0; i < maxLength; i++) {
    final leftValue = i < leftParts.length ? leftParts[i] : 0;
    final rightValue = i < rightParts.length ? rightParts[i] : 0;
    if (leftValue != rightValue) {
      return leftValue.compareTo(rightValue);
    }
  }

  return 0;
}

List<int> _parseVersionParts(String raw) {
  final cleaned = raw.split('+').first.trim();
  if (cleaned.isEmpty) {
    return const <int>[0];
  }

  final matches = RegExp(r'\d+')
      .allMatches(cleaned)
      .map((match) => int.tryParse(match.group(0) ?? '0') ?? 0)
      .toList(growable: false);
  if (matches.isEmpty) {
    return const <int>[0];
  }
  return matches;
}

AppUpdateStatus? _statusFromBackend(String status) {
  final normalized = status.trim().toLowerCase();
  return switch (normalized) {
    'force' || 'required' || 'mandatory' => AppUpdateStatus.updateRequired,
    'soft' || 'optional' || 'recommended' => AppUpdateStatus.updateAvailable,
    'none' ||
    'up_to_date' ||
    'uptodate' ||
    'no_update' => AppUpdateStatus.upToDate,
    _ => null,
  };
}

int _clampHours(
  int value, {
  required int fallback,
  required int min,
  required int max,
}) {
  if (value <= 0) {
    return fallback;
  }
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

String? _storeUrlFromRemoteConfig(FirebaseRemoteConfigService remoteConfig) {
  final key = switch (_platformCode) {
    'android' => _keyStoreUrlAndroid,
    'ios' => _keyStoreUrlIos,
    _ => '',
  };

  if (key.isNotEmpty) {
    final fromConfig = _normalizeText(
      remoteConfig.getString(key, fallback: ''),
    );
    if (fromConfig != null) {
      return fromConfig;
    }
  }

  return switch (_platformCode) {
    'android' => _normalizeText(_envAndroidStoreUrl),
    'ios' => _normalizeText(_envIosStoreUrl),
    _ => null,
  };
}

String get _platformCode => switch (defaultTargetPlatform) {
  TargetPlatform.android => 'android',
  TargetPlatform.iOS => 'ios',
  TargetPlatform.macOS => 'macos',
  TargetPlatform.windows => 'windows',
  TargetPlatform.linux => 'linux',
  TargetPlatform.fuchsia => 'fuchsia',
};

const _releaseChannel = String.fromEnvironment(
  'APP_RELEASE_CHANNEL',
  defaultValue: 'production',
);

const _envAndroidStoreUrl = String.fromEnvironment(
  'APP_UPDATE_STORE_URL_ANDROID',
  defaultValue: '',
);
const _envIosStoreUrl = String.fromEnvironment(
  'APP_UPDATE_STORE_URL_IOS',
  defaultValue: '',
);

const _keyFeatureEnabled = 'app_update_feature_enabled';
const _keyUseBackend = 'app_update_use_backend';
const _keyCheckIntervalHours = 'app_update_check_interval_hours';
const _keySnoozeHours = 'app_update_snooze_hours';
const _keyForceMode = 'app_update_force_mode';
const _keyTitle = 'app_update_title';
const _keyMessage = 'app_update_message';
const _keyStoreUrlAndroid = 'app_update_store_url_android';
const _keyStoreUrlIos = 'app_update_store_url_ios';

String _latestVersionKeyForPlatform() {
  return switch (_platformCode) {
    'android' => 'app_update_latest_android',
    'ios' => 'app_update_latest_ios',
    _ => 'app_update_latest',
  };
}

String _minSupportedVersionKeyForPlatform() {
  return switch (_platformCode) {
    'android' => 'app_update_min_supported_android',
    'ios' => 'app_update_min_supported_ios',
    _ => 'app_update_min_supported',
  };
}
