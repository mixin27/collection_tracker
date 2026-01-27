import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics provider
class FirebaseAnalyticsProvider extends BaseAnalyticsProvider {
  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  @override
  String get name => 'Firebase';

  /// Get observer for navigation tracking
  FirebaseAnalyticsObserver get observer => _observer;

  @override
  Future<void> onInitialize() async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    await _analytics.logEvent(
      name: _sanitizeEventName(event.name),
      parameters: _sanitizeParameters(event.properties),
    );
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: properties?['screen_class'] as String?,
    );
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    await _analytics.setUserId(id: user.id);

    // Set user properties
    for (final entry in user.properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value?.toString(),
      );
    }
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value?.toString(),
      );
    }
  }

  @override
  Future<void> onReset() async {
    await _analytics.setUserId(id: null);
  }

  // Firebase has specific rules for event names and parameters
  String _sanitizeEventName(String name) {
    // Convert to lowercase, replace spaces with underscores
    // Firebase allows max 40 chars
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .substring(0, name.length > 40 ? 40 : name.length);
  }

  Map<String, Object> _sanitizeParameters(Map<String, dynamic> params) {
    final sanitized = <String, Object>{};

    for (final entry in params.entries) {
      final value = entry.value;

      // Firebase only accepts: String, int, double
      if (value is String || value is int || value is double) {
        sanitized[entry.key] = value;
      } else if (value != null) {
        sanitized[entry.key] = value.toString();
      }
    }

    return sanitized;
  }
}
