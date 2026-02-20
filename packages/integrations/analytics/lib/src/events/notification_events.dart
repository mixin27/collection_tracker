import 'package:app_analytics/src/core/analytics_event.dart';

/// Notification events
class NotificationEvents {
  /// Notification received
  static AnalyticsEvent notificationReceived({
    required String notificationType,
    String? campaignId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'notification_received',
      category: 'notification',
      properties: {
        'notification_type': notificationType,
        'campaign_id': ?campaignId,
        ...?properties,
      },
    );
  }

  /// Notification opened
  static AnalyticsEvent notificationOpened({
    required String notificationType,
    String? campaignId,
    String? action,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'notification_opened',
      category: 'notification',
      properties: {
        'notification_type': notificationType,
        'campaign_id': ?campaignId,
        'action': ?action,
        ...?properties,
      },
    );
  }

  /// Notification dismissed
  static AnalyticsEvent notificationDismissed({
    required String notificationType,
    String? campaignId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'notification_dismissed',
      category: 'notification',
      properties: {
        'notification_type': notificationType,
        'campaign_id': ?campaignId,
        ...?properties,
      },
    );
  }

  /// Permission requested
  static AnalyticsEvent permissionRequested({
    required String permissionType,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'permission_requested',
      category: 'notification',
      properties: {'permission_type': permissionType, ...?properties},
    );
  }

  /// Permission granted
  static AnalyticsEvent permissionGranted({
    required String permissionType,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'permission_granted',
      category: 'notification',
      properties: {'permission_type': permissionType, ...?properties},
    );
  }

  /// Permission denied
  static AnalyticsEvent permissionDenied({
    required String permissionType,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'permission_denied',
      category: 'notification',
      properties: {'permission_type': permissionType, ...?properties},
    );
  }
}
