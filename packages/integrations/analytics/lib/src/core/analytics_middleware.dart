import 'analytics_event.dart';

/// Result of middleware processing
enum MiddlewareResult {
  /// Continue to next middleware
  continueProcessing,

  /// Stop processing and track event
  track,

  /// Stop processing and drop event
  drop,
}

/// Middleware for processing analytics events
abstract class AnalyticsMiddleware {
  /// Process an event before sending to providers
  ///
  /// Returns:
  /// - Modified event and continue
  /// - null and continue (event unchanged)
  /// - null and stop (drop event)
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  });

  /// Priority (higher = runs first)
  int get priority => 0;
}
