import 'package:app_analytics/src/core/analytics_event.dart';

/// User engagement and interaction events
class EngagementEvents {
  /// Search performed
  static AnalyticsEvent searchPerformed({
    required String query,
    required int resultCount,
    String? category,
    int? duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'search_performed',
      category: 'engagement',
      properties: {
        'query_length': query.length,
        'result_count': resultCount,
        'category': ?category,
        'duration_ms': ?duration,
        ...?properties,
      },
    );
  }

  /// Filter applied
  static AnalyticsEvent filterApplied({
    required String filterType,
    required dynamic filterValue,
    int? resultCount,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'filter_applied',
      category: 'engagement',
      properties: {
        'filter_type': filterType,
        'filter_value': filterValue.toString(),
        'result_count': ?resultCount,
        ...?properties,
      },
    );
  }

  /// Sort changed
  static AnalyticsEvent sortChanged({
    required String sortBy,
    required String sortOrder, // 'asc' or 'desc'
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'sort_changed',
      category: 'engagement',
      properties: {'sort_by': sortBy, 'sort_order': sortOrder, ...?properties},
    );
  }

  /// Share action
  static AnalyticsEvent shared({
    required String contentType,
    required String contentId,
    required String method, // 'facebook', 'twitter', 'email', etc.
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'content_shared',
      category: 'engagement',
      properties: {
        'content_type': contentType,
        'content_id': contentId,
        'method': method,
        ...?properties,
      },
    );
  }

  /// Favorite/like action
  static AnalyticsEvent favorited({
    required String contentType,
    required String contentId,
    required bool isFavorite,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: isFavorite ? 'item_favorited' : 'item_unfavorited',
      category: 'engagement',
      properties: {
        'content_type': contentType,
        'content_id': contentId,
        ...?properties,
      },
    );
  }

  /// Rating given
  static AnalyticsEvent rated({
    required String contentType,
    required String contentId,
    required double rating,
    double? maxRating,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'content_rated',
      category: 'engagement',
      properties: {
        'content_type': contentType,
        'content_id': contentId,
        'rating': rating,
        'max_rating': ?maxRating,
        ...?properties,
      },
    );
  }

  /// Comment added
  static AnalyticsEvent commented({
    required String contentType,
    required String contentId,
    int? commentLength,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'comment_added',
      category: 'engagement',
      properties: {
        'content_type': contentType,
        'content_id': contentId,
        'comment_length': ?commentLength,
        ...?properties,
      },
    );
  }

  /// Tutorial completed
  static AnalyticsEvent tutorialCompleted({
    required String tutorialName,
    required int stepCount,
    int? duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'tutorial_completed',
      category: 'engagement',
      properties: {
        'tutorial_name': tutorialName,
        'step_count': stepCount,
        'duration_ms': ?duration,
        ...?properties,
      },
    );
  }

  /// Tutorial skipped
  static AnalyticsEvent tutorialSkipped({
    required String tutorialName,
    required int stepNumber,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'tutorial_skipped',
      category: 'engagement',
      properties: {
        'tutorial_name': tutorialName,
        'step_number': stepNumber,
        ...?properties,
      },
    );
  }
}
