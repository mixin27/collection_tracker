import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_user.freezed.dart';
part 'analytics_user.g.dart';

/// Represents user information for analytics
@freezed
abstract class AnalyticsUser with _$AnalyticsUser {
  const factory AnalyticsUser({
    /// Unique user ID
    required String id,

    /// User properties
    @Default({}) Map<String, dynamic> properties,

    /// Anonymous ID (for tracking before login)
    String? anonymousId,

    /// User email (optional, be careful with PII)
    String? email,

    /// User name (optional, be careful with PII)
    String? name,

    /// When user was first seen
    DateTime? createdAt,

    /// Additional metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _AnalyticsUser;

  const AnalyticsUser._();

  factory AnalyticsUser.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsUserFromJson(json);

  /// Create anonymous user
  factory AnalyticsUser.anonymous({
    required String anonymousId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsUser(
      id: anonymousId,
      anonymousId: anonymousId,
      properties: properties ?? {},
      createdAt: DateTime.now(),
    );
  }

  /// Check if user is anonymous
  bool get isAnonymous => anonymousId != null && anonymousId == id;
}
