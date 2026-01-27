import 'analytics_event.dart';
import 'analytics_user.dart';

/// Base interface for all analytics providers
abstract class AnalyticsProvider {
  /// Provider name (e.g., 'Firebase', 'Mixpanel')
  String get name;

  /// Whether this provider is enabled
  bool get isEnabled;

  /// Initialize the provider
  Future<void> initialize();

  /// Track an event
  Future<void> trackEvent(AnalyticsEvent event);

  /// Track screen view
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  });

  /// Identify user
  Future<void> identifyUser(AnalyticsUser user);

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Reset user (logout)
  Future<void> reset();

  /// Flush pending events
  Future<void> flush();

  /// Dispose resources
  Future<void> dispose();
}
