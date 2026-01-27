import 'package:app_analytics/src/core/analytics_event.dart';

/// User action events
class UserEvents {
  /// User signed up
  static AnalyticsEvent signedUp({
    required String method,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'user_signed_up',
      category: 'user',
      properties: {'method': method, ...?properties},
    );
  }

  /// User logged in
  static AnalyticsEvent loggedIn({
    required String method,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'user_logged_in',
      category: 'user',
      properties: {'method': method, ...?properties},
    );
  }

  /// User logged out
  static AnalyticsEvent loggedOut({Map<String, dynamic>? properties}) {
    return AnalyticsEvent.custom(
      name: 'user_logged_out',
      category: 'user',
      properties: properties,
    );
  }

  /// Feature used
  static AnalyticsEvent featureUsed({
    required String featureName,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'feature_used',
      category: 'engagement',
      properties: {'feature_name': featureName, ...?properties},
    );
  }
}
