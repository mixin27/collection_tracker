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

  bool _initialized = false;
  bool _consentGranted = false;

  AnalyticsService._();

  /// Get singleton instance
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  /// Initialize analytics service
  static Future<void> initialize(AnalyticsConfig config) async {
    final service = instance;
    service._config = config;

    // Initialize providers
    for (final provider in config.providers) {
      try {
        await provider.initialize();
        service._providers.add(provider);
      } catch (e) {
        if (config.enableLogging) {
          print('Failed to initialize provider ${provider.name}: $e');
        }
      }
    }

    // Add middleware (sorted by priority)
    final sortedMiddleware = List<AnalyticsMiddleware>.from(config.middleware)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    service._middleware.addAll(sortedMiddleware);

    // Start new session
    service._startNewSession();

    service._initialized = true;

    if (config.enableLogging) {
      print(
        'Analytics initialized with ${service._providers.length} providers',
      );
    }
  }

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Check if consent is granted
  bool get hasConsent => _consentGranted;

  /// Set user consent
  Future<void> setConsentGranted(bool granted) async {
    _consentGranted = granted;

    if (granted) {
      // Flush any queued events
      await flush();
    }
  }

  /// Track an event
  Future<void> track(AnalyticsEvent event) async {
    if (!_initialized) {
      if (_config?.enableLogging ?? false) {
        print('Analytics not initialized');
      }
      return;
    }

    // Check consent if required
    if (_config?.requireConsent ?? false) {
      if (!_consentGranted) {
        if (_config?.enableLogging ?? false) {
          print('Event blocked: consent not granted');
        }
        return;
      }
    }

    // Enrich event with common data
    AnalyticsEvent? enrichedEvent = _enrichEvent(event);

    // Process through middleware
    enrichedEvent = await _processMiddleware(enrichedEvent);
    if (enrichedEvent == null) {
      return; // Event was dropped
    }

    // Send to all providers
    await _sendToProviders(enrichedEvent);
  }

  /// Track screen view
  Future<void> trackScreen(
    String screenName, {
    String? screenClass,
    Map<String, dynamic>? properties,
  }) async {
    await track(
      AnalyticsEvent.screenView(
        screenName: screenName,
        screenClass: screenClass,
        properties: properties,
      ),
    );
  }

  /// Identify user
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

    // Send to all providers
    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.identifyUser(_currentUser!);
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error identifying user in ${provider.name}: $e');
        }
      }
    }
  }

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_initialized) return;

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        properties: {..._currentUser!.properties, ...properties},
      );
    }

    // Send to all providers
    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.setUserProperties(properties);
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error setting user properties in ${provider.name}: $e');
        }
      }
    }
  }

  /// Reset analytics (logout)
  Future<void> reset() async {
    if (!_initialized) return;

    _currentUser = null;
    _startNewSession();

    // Reset all providers
    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.reset();
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error resetting ${provider.name}: $e');
        }
      }
    }
  }

  /// Flush pending events
  Future<void> flush() async {
    if (!_initialized) return;

    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.flush();
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error flushing ${provider.name}: $e');
        }
      }
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    for (final provider in _providers) {
      try {
        await provider.dispose();
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error disposing ${provider.name}: $e');
        }
      }
    }

    _providers.clear();
    _middleware.clear();
    _initialized = false;
    _instance = null;
  }

  // Private methods
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
    // Check session timeout
    if (_isSessionExpired()) {
      _startNewSession();
    }

    // Add common properties
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
      bool shouldContinue = false;

      final result = await middleware.process(
        currentEvent,
        next: (processedEvent) {
          currentEvent = processedEvent;
          shouldContinue = true;
          return true;
        },
      );

      switch (result) {
        case MiddlewareResult.continueProcessing:
          if (!shouldContinue) {
            // If next wasn't called but return was continue, keep original event
            // or should we assume next() must be called?
            // Logic in middleware usually is: return next(modifiedEvent) -> which returns Future<MiddlewareResult>
            // Wait, the signature of process is Future<MiddlewareResult> process(AnalyticsEvent, next).
            // Middleware usually does: return next(modifiedEvent) which is not possible here because next returns bool.

            // The middleware contract is:
            // Future<MiddlewareResult> process(AnalyticsEvent event, {required bool Function(AnalyticsEvent) next})

            // If middleware implementation is:
            // next(modifiedEvent); return MiddlewareResult.continueProcessing;
            // Then we are good with the `shouldContinue` flag or just relying on `currentEvent` update.
          }
          continue;
        case MiddlewareResult.track:
          return currentEvent;
        case MiddlewareResult.drop:
          if (_config?.enableLogging ?? false) {
            print('Event dropped by ${middleware.runtimeType}');
          }
          return null;
      }
    }

    return currentEvent;
  }

  Future<void> _sendToProviders(AnalyticsEvent event) async {
    for (final provider in _providers) {
      if (!provider.isEnabled) continue;

      try {
        await provider.trackEvent(event);
      } catch (e) {
        if (_config?.enableLogging ?? false) {
          print('Error sending event to ${provider.name}: $e');
        }
      }
    }
  }
}
