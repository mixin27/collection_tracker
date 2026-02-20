import 'package:app_analytics/src/core/analytics_event.dart';

/// Media playback events (video, audio)
class MediaEvents {
  /// Media started
  static AnalyticsEvent mediaStarted({
    required String mediaType, // 'video', 'audio'
    required String mediaId,
    required String mediaTitle,
    int? duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'media_started',
      category: 'media',
      properties: {
        'media_type': mediaType,
        'media_id': mediaId,
        'media_title': mediaTitle,
        'duration_seconds': ?duration,
        ...?properties,
      },
    );
  }

  /// Media paused
  static AnalyticsEvent mediaPaused({
    required String mediaType,
    required String mediaId,
    required int position,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'media_paused',
      category: 'media',
      properties: {
        'media_type': mediaType,
        'media_id': mediaId,
        'position_seconds': position,
        ...?properties,
      },
    );
  }

  /// Media completed
  static AnalyticsEvent mediaCompleted({
    required String mediaType,
    required String mediaId,
    required int duration,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'media_completed',
      category: 'media',
      properties: {
        'media_type': mediaType,
        'media_id': mediaId,
        'duration_seconds': duration,
        ...?properties,
      },
    );
  }

  /// Media seek
  static AnalyticsEvent mediaSeeked({
    required String mediaType,
    required String mediaId,
    required int fromPosition,
    required int toPosition,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'media_seeked',
      category: 'media',
      properties: {
        'media_type': mediaType,
        'media_id': mediaId,
        'from_position_seconds': fromPosition,
        'to_position_seconds': toPosition,
        ...?properties,
      },
    );
  }
}
