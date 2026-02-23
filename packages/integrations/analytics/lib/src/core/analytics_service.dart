import 'dart:async';

import 'package:app_analytics/src/events/app_events.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';
import 'package:app_analytics/src/storage/analytics_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'analytics_collection_control.dart';
import 'analytics_config.dart';
import 'analytics_event.dart';
import 'analytics_middleware.dart';
import 'analytics_provider.dart';
import 'analytics_user.dart';

/// Main analytics service - Singleton
class AnalyticsService {
  static AnalyticsService? _instance;

  AnalyticsConfig? _config;
  AnalyticsUser? _currentUser;
  String? _currentSessionId;
  DateTime? _sessionStartTime;

  final List<AnalyticsProvider> _providers = [];
  final List<AnalyticsMiddleware> _middleware = [];
  final Connectivity _connectivity = Connectivity();

  AnalyticsStorage _queueStorage = AnalyticsStorage();
  Timer? _flushTimer;
  _AnalyticsLifecycleObserver? _lifecycleObserver;

  bool _initialized = false;
  bool _consentGranted = false;
  bool _trackingEnabled = true;
  bool _isFlushingQueuedEvents = false;

  AnalyticsService._();

  /// Get singleton instance
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  /// Initialize analytics service
  static Future<void> initialize(AnalyticsConfig config) async {
    final service = instance;
    if (service._initialized) {
      await service._teardownProvidersAndObservers();
    }

    service._config = config;
    service._queueStorage = AnalyticsStorage(maxQueueSize: config.maxQueueSize);
    service._consentGranted = !config.requireConsent;
    service._trackingEnabled = true;
    service._currentUser = null;
    service._currentSessionId = null;
    service._sessionStartTime = null;
    service._isFlushingQueuedEvents = false;

    // Initialize providers
    for (final provider in config.providers) {
      try {
        await provider.initialize();
        service._providers.add(provider);
      } catch (e) {
        service._log('Failed to initialize provider ${provider.name}: $e');
      }
    }

    // Add middleware sorted by priority (higher runs first)
    final sortedMiddleware = List<AnalyticsMiddleware>.from(config.middleware)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    service._middleware.addAll(sortedMiddleware);

    service._startNewSession();
    service._initialized = true;

    service._attachLifecycleObserverIfNeeded();
    service._startFlushTimer();

    if (config.autoTrackAppLifecycle) {
      unawaited(service.track(AppEvents.appOpened()));
    }

    if (!config.requireConsent && config.enableOfflineQueue) {
      unawaited(service.flushQueuedEvents());
    }

    service._log(
      'Analytics initialized with ${service._providers.length} providers',
    );
  }

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Check if analytics event tracking is enabled
  bool get isTrackingEnabled => _trackingEnabled;

  /// Check if consent is granted
  bool get hasConsent => _consentGranted;

  /// Whether configured to auto-track screen views.
  bool get shouldAutoTrackScreenViews => _config?.autoTrackScreenViews ?? true;

  /// Whether offline queueing is enabled by config.
  bool get isOfflineQueueEnabled => _config?.enableOfflineQueue ?? false;

  /// Enable/disable analytics tracking at runtime.
  Future<void> setTrackingEnabled(bool enabled) async {
    _trackingEnabled = enabled;

    for (final provider in _providers) {
      if (provider is BaseAnalyticsProvider) {
        provider.enabled = enabled;
      }
      if (provider is AnalyticsCollectionControl) {
        final collectionControlProvider =
            provider as AnalyticsCollectionControl;
        try {
          await collectionControlProvider.setCollectionEnabled(enabled);
        } catch (e) {
          _log('Unable to set collection state on ${provider.runtimeType}: $e');
        }
      }
    }

    if (enabled) {
      await flush();
    }
  }

  /// Set user consent.
  Future<void> setConsentGranted(bool granted) async {
    _consentGranted = granted;

    if (granted) {
      await flush();
    }
  }

  /// Track an event.
  Future<void> track(AnalyticsEvent event) async {
    if (!_initialized) {
      _log('Analytics not initialized');
      return;
    }

    if (!_canTrackEvents(logBlocked: true)) {
      return;
    }

    final enrichedEvent = _enrichEvent(event);
    final processedEvent = await _processMiddleware(enrichedEvent);
    if (processedEvent == null) {
      return;
    }

    await _sendOrQueue(processedEvent);
  }

  /// Track screen view.
  Future<void> trackScreen(
    String screenName, {
    String? screenClass,
    Map<String, dynamic>? properties,
  }) async {
    if (!shouldAutoTrackScreenViews) {
      return;
    }

    await track(
      AnalyticsEvent.screenView(
        screenName: screenName,
        screenClass: screenClass,
        properties: properties,
      ),
    );
  }

  /// Identify user.
  Future<void> identifyUser({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_initialized) return;

    _currentUser = AnalyticsUser(
      id: userId,
      properties: properties ?? {},
      createdAt: DateTime.now(),
    );

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.identifyUser(_currentUser!);
      } catch (e) {
        _log('Error identifying user in ${provider.name}: $e');
      }
    }
  }

  /// Set user properties.
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_initialized) return;

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        properties: {..._currentUser!.properties, ...properties},
      );
    }

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.setUserProperties(properties);
      } catch (e) {
        _log('Error setting user properties in ${provider.name}: $e');
      }
    }
  }

  /// Reset analytics (logout).
  Future<void> reset() async {
    if (!_initialized) return;

    _currentUser = null;
    _startNewSession();

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.reset();
      } catch (e) {
        _log('Error resetting ${provider.name}: $e');
      }
    }
  }

  /// Flush pending events and queued offline events.
  Future<void> flush() async {
    if (!_initialized) return;

    await flushQueuedEvents();

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.flush();
      } catch (e) {
        _log('Error flushing ${provider.name}: $e');
      }
    }
  }

  /// Check current connectivity status.
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      // Fail open so analytics can still attempt provider delivery.
      _log('Connectivity check failed: $e');
      return true;
    }
  }

  /// Queue an already-processed event for later delivery.
  Future<void> queueEvent(
    AnalyticsEvent event, {
    AnalyticsStorage? storage,
  }) async {
    if (!isOfflineQueueEnabled) return;

    final targetStorage = storage ?? _queueStorage;
    await targetStorage.addToQueue(event);
    _log('Queued event: ${event.name}');
  }

  /// Flush queued events from offline storage.
  Future<void> flushQueuedEvents({AnalyticsStorage? storage}) async {
    if (!_initialized || !isOfflineQueueEnabled) return;
    if (!_canTrackEvents(logBlocked: false)) return;
    if (_isFlushingQueuedEvents) return;
    if (!await isOnline()) return;

    _isFlushingQueuedEvents = true;
    final targetStorage = storage ?? _queueStorage;

    try {
      final queue = await targetStorage.getQueue();
      if (queue.isEmpty) return;

      final failedEvents = <AnalyticsEvent>[];
      for (final queuedEvent in queue) {
        final delivered = await _sendToProviders(queuedEvent);
        if (!delivered) {
          failedEvents.add(queuedEvent);
        }
      }

      if (failedEvents.isEmpty) {
        await targetStorage.clearQueue();
      } else {
        await targetStorage.saveQueue(failedEvents);
      }

      _log(
        'Flushed queued events: ${queue.length - failedEvents.length}/${queue.length}',
      );
    } finally {
      _isFlushingQueuedEvents = false;
    }
  }

  /// Dispose service.
  Future<void> dispose() async {
    await _teardownProvidersAndObservers();
    _initialized = false;
    _trackingEnabled = true;
    _consentGranted = false;
    _currentUser = null;
    _currentSessionId = null;
    _sessionStartTime = null;
    _isFlushingQueuedEvents = false;
    _instance = null;
  }

  Future<void> _teardownProvidersAndObservers() async {
    _stopFlushTimer();
    _detachLifecycleObserver();

    for (final provider in _providers) {
      try {
        await provider.dispose();
      } catch (e) {
        _log('Error disposing ${provider.name}: $e');
      }
    }

    _providers.clear();
    _middleware.clear();
  }

  void _startNewSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
  }

  bool _isSessionExpired() {
    if (_sessionStartTime == null) return true;

    final timeout = Duration(minutes: _config?.sessionTimeout ?? 30);
    return DateTime.now().difference(_sessionStartTime!) > timeout;
  }

  AnalyticsEvent _enrichEvent(AnalyticsEvent event) {
    if (_isSessionExpired()) {
      _startNewSession();
    }

    final enrichedProperties = {
      ...(_config?.commonProperties ?? {}),
      ...event.properties,
    };

    return event.copyWith(
      properties: enrichedProperties,
      userId: _currentUser?.id ?? event.userId,
      sessionId: _currentSessionId ?? event.sessionId,
    );
  }

  Future<AnalyticsEvent?> _processMiddleware(AnalyticsEvent event) async {
    var currentEvent = event;

    for (final middleware in _middleware) {
      final result = await middleware.process(
        currentEvent,
        next: (processedEvent) {
          currentEvent = processedEvent;
          return true;
        },
      );

      if (result == MiddlewareResult.drop) {
        _log('Event dropped by ${middleware.runtimeType}');
        return null;
      }

      if (result == MiddlewareResult.track) {
        break;
      }
    }

    return currentEvent;
  }

  Future<void> _sendOrQueue(AnalyticsEvent event) async {
    if (isOfflineQueueEnabled && !await isOnline()) {
      await queueEvent(event);
      return;
    }

    final delivered = await _sendToProviders(event);
    if (!delivered && isOfflineQueueEnabled) {
      await queueEvent(event);
    }
  }

  Future<bool> _sendToProviders(AnalyticsEvent event) async {
    if (_providers.isEmpty) {
      _log('No analytics providers configured');
      return false;
    }

    var delivered = false;

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.trackEvent(event);
        delivered = true;
      } catch (e) {
        _log('Error sending event to ${provider.name}: $e');
      }
    }

    return delivered;
  }

  bool _canTrackEvents({required bool logBlocked}) {
    if (!_trackingEnabled) {
      if (logBlocked) {
        _log('Event blocked: analytics disabled');
      }
      return false;
    }

    if ((_config?.requireConsent ?? false) && !_consentGranted) {
      if (logBlocked) {
        _log('Event blocked: consent not granted');
      }
      return false;
    }

    return true;
  }

  void _startFlushTimer() {
    _stopFlushTimer();

    final intervalSeconds = _config?.flushInterval ?? 0;
    if (intervalSeconds <= 0) return;

    _flushTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      unawaited(flush());
    });
  }

  void _stopFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  void _attachLifecycleObserverIfNeeded() {
    _detachLifecycleObserver();

    if (!(_config?.autoTrackAppLifecycle ?? false)) {
      return;
    }

    final binding = WidgetsBinding.instance;
    _lifecycleObserver = _AnalyticsLifecycleObserver(this);
    binding.addObserver(_lifecycleObserver!);
  }

  void _detachLifecycleObserver() {
    final observer = _lifecycleObserver;
    if (observer == null) return;

    final binding = WidgetsBinding.instance;
    binding.removeObserver(observer);
    _lifecycleObserver = null;
  }

  void _log(String message) {
    if (_config?.enableLogging ?? false) {
      print(message);
    }
  }
}

class _AnalyticsLifecycleObserver with WidgetsBindingObserver {
  _AnalyticsLifecycleObserver(this._service);

  final AnalyticsService _service;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_service.track(AppEvents.appResumed()));
        break;
      case AppLifecycleState.paused:
        unawaited(_service.track(AppEvents.appBackgrounded()));
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
