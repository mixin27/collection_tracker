import 'dart:async';

import 'package:app_firebase/app_firebase.dart';
import 'package:app_logger/app_logger.dart';
import 'package:auth_session/auth_session.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

import 'auth_session_providers.dart';
import 'firebase_runtime_config_provider.dart';

enum PushNotificationTopic {
  syncNeeded,
  priceAlerts,
  reminders,
  accountSecurity,
}

extension PushNotificationTopicX on PushNotificationTopic {
  String get topicName => switch (this) {
    PushNotificationTopic.syncNeeded => 'sync_needed',
    PushNotificationTopic.priceAlerts => 'price_alerts',
    PushNotificationTopic.reminders => 'reminders',
    PushNotificationTopic.accountSecurity => 'account_security',
  };
}

class PushNotificationPreferencesState {
  static const Object _unset = Object();

  const PushNotificationPreferencesState({
    required this.preferenceEnabled,
    required this.syncNeededEnabled,
    required this.priceAlertsEnabled,
    required this.remindersEnabled,
    required this.accountSecurityEnabled,
    required this.runtimeFeatureEnabled,
    required this.permissionStatus,
    required this.deviceToken,
    required this.apnsToken,
    required this.isApplying,
  });

  final bool preferenceEnabled;
  final bool syncNeededEnabled;
  final bool priceAlertsEnabled;
  final bool remindersEnabled;
  final bool accountSecurityEnabled;
  final bool runtimeFeatureEnabled;
  final FirebaseMessagingPermissionStatus permissionStatus;
  final String? deviceToken;
  final String? apnsToken;
  final bool isApplying;

  bool get isEffectivelyEnabled =>
      runtimeFeatureEnabled && preferenceEnabled && permissionStatus.isGranted;

  PushNotificationPreferencesState copyWith({
    bool? preferenceEnabled,
    bool? syncNeededEnabled,
    bool? priceAlertsEnabled,
    bool? remindersEnabled,
    bool? accountSecurityEnabled,
    bool? runtimeFeatureEnabled,
    FirebaseMessagingPermissionStatus? permissionStatus,
    Object? deviceToken = _unset,
    Object? apnsToken = _unset,
    bool? isApplying,
  }) {
    return PushNotificationPreferencesState(
      preferenceEnabled: preferenceEnabled ?? this.preferenceEnabled,
      syncNeededEnabled: syncNeededEnabled ?? this.syncNeededEnabled,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      accountSecurityEnabled:
          accountSecurityEnabled ?? this.accountSecurityEnabled,
      runtimeFeatureEnabled:
          runtimeFeatureEnabled ?? this.runtimeFeatureEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      deviceToken: identical(deviceToken, _unset)
          ? this.deviceToken
          : deviceToken as String?,
      apnsToken: identical(apnsToken, _unset)
          ? this.apnsToken
          : apnsToken as String?,
      isApplying: isApplying ?? this.isApplying,
    );
  }
}

final pushNotificationPreferencesProvider =
    NotifierProvider<
      PushNotificationPreferencesController,
      PushNotificationPreferencesState
    >(PushNotificationPreferencesController.new);

class PushNotificationPreferencesController
    extends Notifier<PushNotificationPreferencesState> {
  static const _enabledKey = 'push_notifications_enabled';
  static const _topicSyncKey = 'push_topic_sync_needed';
  static const _topicPriceKey = 'push_topic_price_alerts';
  static const _topicReminderKey = 'push_topic_reminders';
  static const _topicSecurityKey = 'push_topic_account_security';
  static const _tokenKey = 'push_device_token';
  static const _apnsTokenKey = 'push_apns_token';

  late final PrefsStorageService _prefs;
  StreamSubscription<String>? _tokenRefreshSubscription;
  Set<String> _subscribedTopics = <String>{};
  bool _bootstrapped = false;

  @override
  PushNotificationPreferencesState build() {
    _prefs = PrefsStorageService.instance;

    ref.listen<FirebaseRuntimeConfig>(firebaseRuntimeConfigProvider, (
      previous,
      next,
    ) {
      if (previous?.fcmEnabled == next.fcmEnabled) {
        return;
      }
      unawaited(
        _applyMessagingConfiguration(
          runtimeFeatureEnabled: next.fcmEnabled,
          reason: 'runtime_config',
        ),
      );
    });

    ref.listen<AsyncValue<AuthSession>>(authSessionProvider, (previous, next) {
      final wasAuthenticated = previous?.value?.isAuthenticated ?? false;
      final isAuthenticated = next.value?.isAuthenticated ?? false;
      if (wasAuthenticated == isAuthenticated) {
        return;
      }
      unawaited(_applyTopicSubscriptions(reason: 'auth_state_change'));
    });

    ref.onDispose(() async {
      await _tokenRefreshSubscription?.cancel();
    });

    final initial = PushNotificationPreferencesState(
      preferenceEnabled: _prefs.readSync<bool>(_enabledKey) ?? false,
      syncNeededEnabled: _prefs.readSync<bool>(_topicSyncKey) ?? true,
      priceAlertsEnabled: _prefs.readSync<bool>(_topicPriceKey) ?? true,
      remindersEnabled: _prefs.readSync<bool>(_topicReminderKey) ?? true,
      accountSecurityEnabled: _prefs.readSync<bool>(_topicSecurityKey) ?? true,
      runtimeFeatureEnabled: ref.read(firebaseRuntimeConfigProvider).fcmEnabled,
      permissionStatus: FirebaseMessagingPermissionStatus.notDetermined,
      deviceToken: _prefs.readSync<String>(_tokenKey),
      apnsToken: _prefs.readSync<String>(_apnsTokenKey),
      isApplying: false,
    );

    if (!_bootstrapped) {
      _bootstrapped = true;
      unawaited(_bootstrap());
    }

    return initial;
  }

  Future<void> setPreferenceEnabled(bool enabled) async {
    var permission = state.permissionStatus;
    if (enabled && !permission.isGranted) {
      permission = await FirebaseMessagingService.instance.requestPermission();
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(permissionStatus: permission);
      await OperationalTelemetry.trackPushPermission(
        status: permission.name,
        preferenceEnabled: enabled,
        runtimeEnabled: state.runtimeFeatureEnabled,
      );
    }

    final canEnable = !enabled || permission.isGranted;
    final nextEnabled = enabled && canEnable;

    await _prefs.save<bool>(_enabledKey, nextEnabled);
    state = state.copyWith(preferenceEnabled: nextEnabled);

    await _applyMessagingConfiguration(reason: 'preference_toggle');
  }

  Future<void> setTopicEnabled(
    PushNotificationTopic topic,
    bool enabled,
  ) async {
    final prefKey = switch (topic) {
      PushNotificationTopic.syncNeeded => _topicSyncKey,
      PushNotificationTopic.priceAlerts => _topicPriceKey,
      PushNotificationTopic.reminders => _topicReminderKey,
      PushNotificationTopic.accountSecurity => _topicSecurityKey,
    };

    await _prefs.save<bool>(prefKey, enabled);

    state = switch (topic) {
      PushNotificationTopic.syncNeeded => state.copyWith(
        syncNeededEnabled: enabled,
      ),
      PushNotificationTopic.priceAlerts => state.copyWith(
        priceAlertsEnabled: enabled,
      ),
      PushNotificationTopic.reminders => state.copyWith(
        remindersEnabled: enabled,
      ),
      PushNotificationTopic.accountSecurity => state.copyWith(
        accountSecurityEnabled: enabled,
      ),
    };

    await _applyTopicSubscriptions(reason: 'topic_toggle');
  }

  Future<void> refreshPermissionStatus() async {
    final permission = await FirebaseMessagingService.instance
        .getPermissionStatus();
    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(permissionStatus: permission);
    await OperationalTelemetry.trackPushPermission(
      status: permission.name,
      preferenceEnabled: state.preferenceEnabled,
      runtimeEnabled: state.runtimeFeatureEnabled,
    );
    await _refreshApnsTokenStatus();
    await _applyMessagingConfiguration(reason: 'permission_refresh');
  }

  Future<void> handleTokenUpdated(String token, {String source = 'stream'}) {
    return _handleTokenUpdate(token, source: source);
  }

  Future<void> _bootstrap() async {
    _tokenRefreshSubscription = FirebaseMessagingService.instance.onTokenRefresh
        .listen((token) {
          unawaited(_handleTokenUpdate(token, source: 'refresh_stream'));
        });

    final permission = await FirebaseMessagingService.instance
        .getPermissionStatus();
    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(permissionStatus: permission);
    await OperationalTelemetry.trackPushPermission(
      status: permission.name,
      preferenceEnabled: state.preferenceEnabled,
      runtimeEnabled: state.runtimeFeatureEnabled,
    );
    await _refreshApnsTokenStatus();

    await _applyMessagingConfiguration(reason: 'bootstrap');

    final token = await FirebaseMessagingService.instance.getToken();
    if (!ref.mounted || token == null || token.trim().isEmpty) {
      return;
    }
    await _handleTokenUpdate(token, source: 'bootstrap');
  }

  Future<void> _applyMessagingConfiguration({
    bool? runtimeFeatureEnabled,
    required String reason,
  }) async {
    final runtimeEnabled =
        runtimeFeatureEnabled ??
        ref.read(firebaseRuntimeConfigProvider).fcmEnabled;
    final effectiveEnabled =
        runtimeEnabled &&
        state.preferenceEnabled &&
        state.permissionStatus.isGranted;

    state = state.copyWith(
      runtimeFeatureEnabled: runtimeEnabled,
      isApplying: true,
    );

    await FirebaseMessagingService.instance.setEnabled(effectiveEnabled);

    if (!ref.mounted) {
      return;
    }

    if (!effectiveEnabled) {
      await _unsubscribeAllTopics();
      state = state.copyWith(isApplying: false);
      Logger.info(
        'Push notifications disabled (runtime=$runtimeEnabled, '
        'preference=${state.preferenceEnabled}, '
        'permission=${state.permissionStatus.name}, reason=$reason).',
      );
      return;
    }

    await _refreshApnsTokenStatus();
    await _applyTopicSubscriptions(reason: reason);

    final token = await FirebaseMessagingService.instance.getToken();
    if (!ref.mounted) {
      return;
    }
    if (token != null && token.trim().isNotEmpty) {
      await _handleTokenUpdate(token, source: 'config_apply');
    }

    state = state.copyWith(isApplying: false);
  }

  Future<void> _refreshApnsTokenStatus() async {
    final apnsToken = await FirebaseMessagingService.instance.getApnsToken();
    if (!ref.mounted) {
      return;
    }

    final sanitized = apnsToken?.trim();
    if (sanitized != null && sanitized.isNotEmpty) {
      await _prefs.save<String>(_apnsTokenKey, sanitized);
      state = state.copyWith(apnsToken: sanitized);
      return;
    }

    state = state.copyWith(apnsToken: null);
  }

  Future<void> _applyTopicSubscriptions({required String reason}) async {
    if (!state.isEffectivelyEnabled) {
      await _unsubscribeAllTopics();
      if (ref.mounted) {
        state = state.copyWith(isApplying: false);
      }
      return;
    }

    final isAuthenticated =
        ref.read(authSessionProvider).value?.isAuthenticated ?? false;
    final desiredTopics = <String>{
      if (state.syncNeededEnabled) PushNotificationTopic.syncNeeded.topicName,
      if (state.priceAlertsEnabled) PushNotificationTopic.priceAlerts.topicName,
      if (state.remindersEnabled) PushNotificationTopic.reminders.topicName,
      if (state.accountSecurityEnabled && isAuthenticated)
        PushNotificationTopic.accountSecurity.topicName,
    };

    final topicsToUnsubscribe = _subscribedTopics.difference(desiredTopics);
    for (final topic in topicsToUnsubscribe) {
      await FirebaseMessagingService.instance.unsubscribeFromTopic(topic);
    }

    final topicsToSubscribe = desiredTopics.difference(_subscribedTopics);
    for (final topic in topicsToSubscribe) {
      await FirebaseMessagingService.instance.subscribeToTopic(topic);
    }

    _subscribedTopics = desiredTopics;
    if (ref.mounted) {
      state = state.copyWith(isApplying: false);
    }
    Logger.info(
      'Push topic subscriptions updated (${_subscribedTopics.join(",")}) '
      '(reason=$reason).',
    );
  }

  Future<void> _unsubscribeAllTopics() async {
    if (_subscribedTopics.isEmpty) {
      _subscribedTopics = <String>{};
      return;
    }

    for (final topic in _subscribedTopics) {
      await FirebaseMessagingService.instance.unsubscribeFromTopic(topic);
    }
    _subscribedTopics = <String>{};
  }

  Future<void> _handleTokenUpdate(
    String token, {
    required String source,
  }) async {
    final sanitized = token.trim();
    if (sanitized.isEmpty) {
      return;
    }

    await _prefs.save<String>(_tokenKey, sanitized);

    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(deviceToken: sanitized);
    await OperationalTelemetry.trackPushTokenUpdate(
      hasToken: true,
      source: source,
    );
  }
}
