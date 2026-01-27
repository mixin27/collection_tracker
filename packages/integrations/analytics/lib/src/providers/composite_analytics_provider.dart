import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_provider.dart';
import 'package:app_analytics/src/core/analytics_user.dart';

/// Composite provider that sends to multiple providers
/// This is handled by AnalyticsService, but can be used standalone
class CompositeAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsProvider> providers;

  CompositeAnalyticsProvider(this.providers);

  @override
  String get name => 'Composite(${providers.map((p) => p.name).join(', ')})';

  @override
  bool get isEnabled => providers.any((p) => p.isEnabled);

  @override
  Future<void> initialize() async {
    await Future.wait(providers.map((p) => p.initialize()));
  }

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    await Future.wait(
      providers.where((p) => p.isEnabled).map((p) => p.trackEvent(event)),
    );
  }

  @override
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await Future.wait(
      providers
          .where((p) => p.isEnabled)
          .map((p) => p.trackScreen(screenName, properties: properties)),
    );
  }

  @override
  Future<void> identifyUser(AnalyticsUser user) async {
    await Future.wait(
      providers.where((p) => p.isEnabled).map((p) => p.identifyUser(user)),
    );
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    await Future.wait(
      providers
          .where((p) => p.isEnabled)
          .map((p) => p.setUserProperties(properties)),
    );
  }

  @override
  Future<void> reset() async {
    await Future.wait(
      providers.where((p) => p.isEnabled).map((p) => p.reset()),
    );
  }

  @override
  Future<void> flush() async {
    await Future.wait(
      providers.where((p) => p.isEnabled).map((p) => p.flush()),
    );
  }

  @override
  Future<void> dispose() async {
    await Future.wait(providers.map((p) => p.dispose()));
  }
}
