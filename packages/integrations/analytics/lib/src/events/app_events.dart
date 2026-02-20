import 'package:app_analytics/src/core/analytics_event.dart';

/// Common app lifecycle events
class AppEvents {
  /// App opened/launched
  static AnalyticsEvent appOpened({
    String? source,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'app_opened',
      category: 'lifecycle',
      properties: {'source': ?source, ...?properties},
    );
  }

  /// App backgrounded
  static AnalyticsEvent appBackgrounded({Map<String, dynamic>? properties}) {
    return AnalyticsEvent.custom(
      name: 'app_backgrounded',
      category: 'lifecycle',
      properties: properties,
    );
  }

  /// App resumed/foregrounded
  static AnalyticsEvent appResumed({Map<String, dynamic>? properties}) {
    return AnalyticsEvent.custom(
      name: 'app_resumed',
      category: 'lifecycle',
      properties: properties,
    );
  }

  /// App crashed
  static AnalyticsEvent appCrashed({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'app_crashed',
      category: 'error',
      properties: {'error': error, 'stack_trace': ?stackTrace, ...?properties},
    );
  }

  /// Error occurred
  static AnalyticsEvent errorOccurred({
    required String error,
    String? screen,
    String? context,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'error_occurred',
      category: 'error',
      properties: {
        'error': error,
        'screen': ?screen,
        'context': ?context,
        ...?properties,
      },
    );
  }
}
