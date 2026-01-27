import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_user.dart';
import 'package:app_analytics/src/providers/base_analytics_provider.dart';

/// Console provider for debugging - prints events to console
class ConsoleAnalyticsProvider extends BaseAnalyticsProvider {
  ConsoleAnalyticsProvider({this.prettyPrint = true});

  final bool prettyPrint;

  @override
  String get name => 'Console';

  @override
  Future<void> onInitialize() async {
    print('📊 [Analytics] Console provider initialized');
  }

  @override
  Future<void> onTrackEvent(AnalyticsEvent event) async {
    if (prettyPrint) {
      print('📊 [Analytics] Event: ${event.name}');
      print('   Category: ${event.category ?? "N/A"}');
      print('   Properties: ${event.properties}');
      if (event.value != null) {
        print('   Value: ${event.value} ${event.currency ?? ""}');
      }
    } else {
      print('📊 [Analytics] ${event.name}: ${event.properties}');
    }
  }

  @override
  Future<void> onTrackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    print('📊 [Analytics] Screen: $screenName ${properties ?? ""}');
  }

  @override
  Future<void> onIdentifyUser(AnalyticsUser user) async {
    print('📊 [Analytics] Identify User: ${user.id}');
    print('   Properties: ${user.properties}');
  }

  @override
  Future<void> onSetUserProperties(Map<String, dynamic> properties) async {
    print('📊 [Analytics] Set User Properties: $properties');
  }

  @override
  Future<void> onReset() async {
    print('📊 [Analytics] Reset (logout)');
  }
}
