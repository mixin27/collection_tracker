import 'package:app_analytics/src/core/analytics_event.dart';

/// Performance and error events
class PerformanceEvents {
  /// API call completed
  static AnalyticsEvent apiCallCompleted({
    required String endpoint,
    required int duration,
    required int statusCode,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'api_call_completed',
      category: 'performance',
      properties: {
        'endpoint': endpoint,
        'duration_ms': duration,
        'status_code': statusCode,
        ...?properties,
      },
    );
  }

  /// API call failed
  static AnalyticsEvent apiCallFailed({
    required String endpoint,
    required String error,
    int? statusCode,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'api_call_failed',
      category: 'performance',
      properties: {
        'endpoint': endpoint,
        'error': error,
        'status_code': ?statusCode,
        ...?properties,
      },
    );
  }

  /// Screen load time
  static AnalyticsEvent screenLoadTime({
    required String screenName,
    required int duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'screen_load_time',
      category: 'performance',
      properties: {
        'screen_name': screenName,
        'duration_ms': duration,
        ...?properties,
      },
    );
  }

  /// Frame drop detected
  static AnalyticsEvent frameDropDetected({
    required String screenName,
    required int droppedFrames,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'frame_drop_detected',
      category: 'performance',
      properties: {
        'screen_name': screenName,
        'dropped_frames': droppedFrames,
        ...?properties,
      },
    );
  }
}
