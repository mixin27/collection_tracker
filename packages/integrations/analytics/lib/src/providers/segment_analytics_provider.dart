import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/state.dart';

/// Segment Analytics provider
/// Segment is a customer data platform that routes data to multiple destinations
class SegmentAnalyticsProvider extends BaseAnalyticsProvider {
  final String writeKey;
  late Analytics _segment;

  String? _userId;

  SegmentAnalyticsProvider({required this.writeKey});

  @override
  String get name => 'Segment';

  @override
  Future<void> onInitialize() async {
    createClient(
      Configuration(writeKey, trackApplicationLifecycleEvents: false),
    );
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    await _segment.track(event.name, properties: event.properties);
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await _segment.screen(screenName, properties: properties ?? {});
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    _userId = user.id;
    final userTraits = UserTraits(
      id: user.id,
      email: user.email,
      firstName: user.name,
      createdAt: user.createdAt?.toIso8601String(),
      custom: {"anonymousId": user.anonymousId, ...user.properties},
    );
    await _segment.identify(userId: user.id, userTraits: userTraits);
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    // Segment doesn't have separate setUserProperties
    // Properties are set with identify
    if (_userId != null) {
      await _segment.identify(
        userId: _userId,
        userTraits: UserTraits(custom: properties),
      );
    }
  }

  @override
  Future<void> onReset() async {
    await _segment.reset();
  }

  @override
  Future<void> onFlush() async {
    await _segment.flush();
  }
}
