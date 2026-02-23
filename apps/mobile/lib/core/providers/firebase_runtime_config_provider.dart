import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/bootstrap/firebase_services_bootstrap.dart';
import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseRuntimeConfigState {
  const FirebaseRuntimeConfigState({
    required this.config,
    required this.remoteConfigStatus,
    required this.isRefreshing,
  });

  final FirebaseRuntimeConfig config;
  final FirebaseRemoteConfigStatus remoteConfigStatus;
  final bool isRefreshing;

  FirebaseRuntimeConfigState copyWith({
    FirebaseRuntimeConfig? config,
    FirebaseRemoteConfigStatus? remoteConfigStatus,
    bool? isRefreshing,
  }) {
    return FirebaseRuntimeConfigState(
      config: config ?? this.config,
      remoteConfigStatus: remoteConfigStatus ?? this.remoteConfigStatus,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final initialFirebaseRuntimeConfigProvider = Provider<FirebaseRuntimeConfig>(
  (ref) => FirebaseRuntimeConfig.defaults,
);

final firebaseRuntimeConfigControllerProvider =
    NotifierProvider<
      FirebaseRuntimeConfigController,
      FirebaseRuntimeConfigState
    >(FirebaseRuntimeConfigController.new);

class FirebaseRuntimeConfigController
    extends Notifier<FirebaseRuntimeConfigState> {
  static final Duration _defaultResumeRefreshThrottle = kDebugMode
      ? const Duration(minutes: 1)
      : const Duration(minutes: 15);

  DateTime? _lastAutoRefreshAttempt;

  @override
  FirebaseRuntimeConfigState build() {
    final initialConfig = ref.watch(initialFirebaseRuntimeConfigProvider);
    return FirebaseRuntimeConfigState(
      config: initialConfig,
      remoteConfigStatus: FirebaseRemoteConfigService.instance.status,
      isRefreshing: false,
    );
  }

  Future<FirebaseRuntimeConfigRefreshResult> refreshFromRemoteConfig({
    bool forceFetch = false,
  }) async {
    if (state.isRefreshing) {
      return FirebaseRuntimeConfigRefreshResult(
        runtimeConfig: state.config,
        status: state.remoteConfigStatus,
        didActivateChanges: false,
      );
    }

    state = state.copyWith(isRefreshing: true);

    try {
      final result = await FirebaseServicesBootstrap.refreshRuntimeConfig(
        forceFetch: forceFetch,
      );
      state = state.copyWith(
        config: result.runtimeConfig,
        remoteConfigStatus: result.status,
        isRefreshing: false,
      );
      return result;
    } catch (_) {
      state = state.copyWith(
        remoteConfigStatus: FirebaseRemoteConfigService.instance.status,
        isRefreshing: false,
      );
      rethrow;
    }
  }

  Future<FirebaseRuntimeConfigRefreshResult?> refreshFromRemoteConfigIfDue({
    Duration? minimumInterval,
    DateTime? now,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    final throttle = minimumInterval ?? _defaultResumeRefreshThrottle;
    final previousAttempt = _lastAutoRefreshAttempt;

    if (previousAttempt != null &&
        effectiveNow.difference(previousAttempt) < throttle) {
      return null;
    }

    _lastAutoRefreshAttempt = effectiveNow;
    return refreshFromRemoteConfig();
  }
}

final firebaseRuntimeConfigProvider = Provider<FirebaseRuntimeConfig>(
  (ref) => ref.watch(firebaseRuntimeConfigControllerProvider).config,
);

final firebaseRemoteConfigStatusProvider = Provider<FirebaseRemoteConfigStatus>(
  (ref) =>
      ref.watch(firebaseRuntimeConfigControllerProvider).remoteConfigStatus,
);

final firebaseRuntimeConfigRefreshInProgressProvider = Provider<bool>(
  (ref) => ref.watch(firebaseRuntimeConfigControllerProvider).isRefreshing,
);
