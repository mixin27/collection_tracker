import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel Analytics provider
class MixpanelAnalyticsProvider extends BaseAnalyticsProvider {
  final String token;
  late Mixpanel _mixpanel;

  MixpanelAnalyticsProvider({required this.token});

  @override
  String get name => 'Mixpanel';

  @override
  Future<void> onInitialize() async {
    _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: false);
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    _mixpanel.track(event.name, properties: event.properties);
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    _mixpanel.track(
      'Screen View',
      properties: {'screen_name': screenName, ...?properties},
    );
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    _mixpanel.identify(user.id);

    // Set user properties
    _mixpanel.getPeople().set('\$name', user.name ?? user.id);

    for (final entry in user.properties.entries) {
      _mixpanel.getPeople().set(entry.key, entry.value);
    }
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    for (final entry in properties.entries) {
      _mixpanel.getPeople().set(entry.key, entry.value);
    }
  }

  @override
  Future<void> onReset() async {
    _mixpanel.reset();
  }

  @override
  Future<void> onFlush() async {
    _mixpanel.flush();
  }
}
