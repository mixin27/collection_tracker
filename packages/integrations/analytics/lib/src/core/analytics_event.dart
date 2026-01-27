import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_event.freezed.dart';
part 'analytics_event.g.dart';

/// Represents an analytics event with properties
@freezed
abstract class AnalyticsEvent with _$AnalyticsEvent {
  const factory AnalyticsEvent({
    /// Event name (e.g., 'button_clicked', 'screen_view')
    required String name,

    /// Event properties
    @Default({}) Map<String, dynamic> properties,

    /// Timestamp when event was created
    required DateTime timestamp,

    /// Optional event category for organization
    String? category,

    /// Event value (for conversions, revenue, etc.)
    double? value,

    /// Currency for value (if applicable)
    String? currency,

    /// User ID associated with this event
    String? userId,

    /// Session ID
    String? sessionId,

    /// Additional metadata (not sent to analytics, used internally)
    @Default({}) Map<String, dynamic> metadata,
  }) = _AnalyticsEvent;

  const AnalyticsEvent._();

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsEventFromJson(json);

  /// Create a custom event
  factory AnalyticsEvent.custom({
    required String name,
    Map<String, dynamic>? properties,
    String? category,
    double? value,
    String? currency,
  }) {
    return AnalyticsEvent(
      name: name,
      properties: properties ?? {},
      timestamp: DateTime.now(),
      category: category,
      value: value,
      currency: currency,
    );
  }

  /// Create a screen view event
  factory AnalyticsEvent.screenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent(
      name: 'screen_view',
      properties: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
        ...?properties,
      },
      timestamp: DateTime.now(),
      category: 'navigation',
    );
  }

  /// Create a button click event
  factory AnalyticsEvent.buttonClicked({
    required String buttonName,
    String? screenName,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent(
      name: 'button_clicked',
      properties: {
        'button_name': buttonName,
        if (screenName != null) 'screen_name': screenName,
        ...?properties,
      },
      timestamp: DateTime.now(),
      category: 'engagement',
    );
  }

  /// Merge additional properties
  AnalyticsEvent withProperties(Map<String, dynamic> additionalProperties) {
    return copyWith(properties: {...properties, ...additionalProperties});
  }

  /// Add metadata
  AnalyticsEvent withMetadata(Map<String, dynamic> additionalMetadata) {
    return copyWith(metadata: {...metadata, ...additionalMetadata});
  }
}
