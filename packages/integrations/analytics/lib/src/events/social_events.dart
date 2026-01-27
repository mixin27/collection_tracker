import 'package:app_analytics/src/core/analytics_event.dart';

/// Social interaction events
class SocialEvents {
  /// User invited
  static AnalyticsEvent userInvited({
    required String method, // 'email', 'sms', 'link', etc.
    int? inviteCount,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'user_invited',
      category: 'social',
      properties: {
        'method': method,
        if (inviteCount != null) 'invite_count': inviteCount,
        ...?properties,
      },
    );
  }

  /// Invite accepted
  static AnalyticsEvent inviteAccepted({
    required String referralCode,
    String? referrerId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'invite_accepted',
      category: 'social',
      properties: {
        'referral_code': referralCode,
        if (referrerId != null) 'referrer_id': referrerId,
        ...?properties,
      },
    );
  }

  /// Profile viewed
  static AnalyticsEvent profileViewed({
    required String profileId,
    String? profileType,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'profile_viewed',
      category: 'social',
      properties: {
        'profile_id': profileId,
        if (profileType != null) 'profile_type': profileType,
        ...?properties,
      },
    );
  }

  /// User followed
  static AnalyticsEvent userFollowed({
    required String followedUserId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'user_followed',
      category: 'social',
      properties: {'followed_user_id': followedUserId, ...?properties},
    );
  }

  /// User unfollowed
  static AnalyticsEvent userUnfollowed({
    required String unfollowedUserId,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'user_unfollowed',
      category: 'social',
      properties: {'unfollowed_user_id': unfollowedUserId, ...?properties},
    );
  }
}
