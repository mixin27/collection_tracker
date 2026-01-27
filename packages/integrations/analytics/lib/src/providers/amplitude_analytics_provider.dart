import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';

/// Amplitude Analytics provider
class AmplitudeAnalyticsProvider extends BaseAnalyticsProvider {
  final String apiKey;
  late Amplitude _amplitude;

  AmplitudeAnalyticsProvider({required this.apiKey});

  @override
  String get name => 'Amplitude';

  @override
  Future<void> onInitialize() async {
    _amplitude = Amplitude(Configuration(apiKey: apiKey));
    await _amplitude.isBuilt;
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    await _amplitude.track(
      BaseEvent(event.name, eventProperties: event.properties),
    );
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await _amplitude.track(
      BaseEvent(
        'Screen View',
        eventProperties: {'screen_name': screenName, ...?properties},
      ),
    );
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    await _amplitude.setUserId(user.id);

    final identify = Identify();
    for (final entry in user.properties.entries) {
      identify.set(entry.key, entry.value);
    }

    await _amplitude.identify(identify);
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    final identify = Identify();
    for (final entry in properties.entries) {
      identify.set(entry.key, entry.value);
    }

    await _amplitude.identify(identify);
  }

  @override
  Future<void> onReset() async {
    final Identify identify = Identify()..clearAll();
    await _amplitude.identify(identify);
    await _amplitude.setUserId(null);
  }

  @override
  Future<void> onFlush() async {
    await _amplitude.flush();
  }
}
