import 'package:app_analytics/src/core/analytics_event.dart';

/// Form interaction events
class FormEvents {
  /// Form started
  static AnalyticsEvent formStarted({
    required String formName,
    String? formId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'form_started',
      category: 'form',
      properties: {'form_name': formName, 'form_id': ?formId, ...?properties},
    );
  }

  /// Form completed
  static AnalyticsEvent formCompleted({
    required String formName,
    String? formId,
    int? duration,
    int? fieldCount,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'form_completed',
      category: 'form',
      properties: {
        'form_name': formName,
        'form_id': ?formId,
        'duration_ms': ?duration,
        'field_count': ?fieldCount,
        ...?properties,
      },
    );
  }

  /// Form abandoned
  static AnalyticsEvent formAbandoned({
    required String formName,
    String? formId,
    int? lastFieldIndex,
    int? duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'form_abandoned',
      category: 'form',
      properties: {
        'form_name': formName,
        'form_id': ?formId,
        'last_field_index': ?lastFieldIndex,
        'duration_ms': ?duration,
        ...?properties,
      },
    );
  }

  /// Form error
  static AnalyticsEvent formError({
    required String formName,
    required String fieldName,
    required String errorType,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'form_error',
      category: 'form',
      properties: {
        'form_name': formName,
        'field_name': fieldName,
        'error_type': errorType,
        ...?properties,
      },
    );
  }

  /// Field focused
  static AnalyticsEvent fieldFocused({
    required String formName,
    required String fieldName,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'field_focused',
      category: 'form',
      properties: {
        'form_name': formName,
        'field_name': fieldName,
        ...?properties,
      },
    );
  }

  /// Field completed
  static AnalyticsEvent fieldCompleted({
    required String formName,
    required String fieldName,
    int? duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'field_completed',
      category: 'form',
      properties: {
        'form_name': formName,
        'field_name': fieldName,
        'duration_ms': ?duration,
        ...?properties,
      },
    );
  }
}
