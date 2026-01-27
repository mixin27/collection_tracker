import 'package:app_analytics/src/core/analytics_event.dart';

/// Screen navigation and view events
class ScreenEvents {
  /// Screen viewed
  static AnalyticsEvent screenViewed({
    required String screenName,
    String? screenClass,
    String? previousScreen,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'screen_view',
      category: 'navigation',
      properties: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
        if (previousScreen != null) 'previous_screen': previousScreen,
        ...?properties,
      },
    );
  }

  /// Tab selected
  static AnalyticsEvent tabSelected({
    required String tabName,
    required int tabIndex,
    String? screenName,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'tab_selected',
      category: 'navigation',
      properties: {
        'tab_name': tabName,
        'tab_index': tabIndex,
        if (screenName != null) 'screen_name': screenName,
        ...?properties,
      },
    );
  }

  /// Modal opened
  static AnalyticsEvent modalOpened({
    required String modalName,
    String? trigger,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'modal_opened',
      category: 'navigation',
      properties: {
        'modal_name': modalName,
        if (trigger != null) 'trigger': trigger,
        ...?properties,
      },
    );
  }

  /// Modal closed
  static AnalyticsEvent modalClosed({
    required String modalName,
    String? action, // 'submit', 'cancel', 'close'
    int? timeSpent,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'modal_closed',
      category: 'navigation',
      properties: {
        'modal_name': modalName,
        if (action != null) 'action': action,
        if (timeSpent != null) 'time_spent_ms': timeSpent,
        ...?properties,
      },
    );
  }

  /// Deep link opened
  static AnalyticsEvent deepLinkOpened({
    required String deepLink,
    String? source,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'deep_link_opened',
      category: 'navigation',
      properties: {
        'deep_link': deepLink,
        if (source != null) 'source': source,
        ...?properties,
      },
    );
  }
}
