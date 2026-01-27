import 'package:app_analytics/src/core/analytics_event.dart';

class CustomEvents {
  /// Custom event
  static AnalyticsEvent customEvent({
    required String name,
    String? category,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: name,
      category: category,
      properties: properties,
    );
  }

  /// Custom event with value
  static AnalyticsEvent customEventWithValue({
    required String name,
    String? category,
    double? value,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: name,
      category: category,
      value: value,
      properties: properties,
    );
  }

  /// Custom event with currency
  static AnalyticsEvent customEventWithCurrency({
    required String name,
    String? category,
    double? value,
    String? currency,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: name,
      category: category,
      value: value,
      currency: currency,
      properties: properties,
    );
  }

  /// Custom event with value and currency
  static AnalyticsEvent customEventWithValueAndCurrency({
    required String name,
    String? category,
    double? value,
    String? currency,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: name,
      category: category,
      value: value,
      currency: currency,
      properties: properties,
    );
  }
}
