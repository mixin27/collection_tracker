import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_provider.dart';
import 'package:app_analytics/src/core/analytics_user.dart';

/// Base implementation of AnalyticsProvider with common functionality
abstract class BaseAnalyticsProvider implements AnalyticsProvider {
  bool _enabled = true;
  bool _initialized = false;

  @override
  bool get isEnabled => _enabled && _initialized;

  /// Enable/disable this provider
  set enabled(bool value) => _enabled = value;

  /// Check if initialized
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await onInitialize();
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize $name: $e');
    }
  }

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    if (!isEnabled) return;
    await onTrackEvent(event);
  }

  @override
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!isEnabled) return;
    await onTrackScreen(screenName, properties: properties);
  }

  @override
  Future<void> identifyUser(AnalyticsUser user) async {
    if (!isEnabled) return;
    await onIdentifyUser(user);
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!isEnabled) return;
    await onSetUserProperties(properties);
  }

  @override
  Future<void> reset() async {
    if (!isEnabled) return;
    await onReset();
  }

  @override
  Future<void> flush() async {
    if (!isEnabled) return;
    await onFlush();
  }

  @override
  Future<void> dispose() async {
    await onDispose();
    _initialized = false;
  }

  // Protected methods to override
  Future<void> onInitialize();
  Future<void> onTrackEvent(AnalyticsEvent event);
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  });
  Future<void> onIdentifyUser(AnalyticsUser user);
  Future<void> onSetUserProperties(Map<String, dynamic> properties);
  Future<void> onReset();
  Future<void> onFlush() async {}
  Future<void> onDispose() async {}
}
