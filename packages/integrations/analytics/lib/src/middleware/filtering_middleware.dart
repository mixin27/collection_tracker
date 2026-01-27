import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';

/// Middleware to filter events based on rules
class FilteringMiddleware implements AnalyticsMiddleware {
  late final List<String> _blockedEvents;
  late final List<String> _allowedEvents;
  final bool _useAllowlist;

  FilteringMiddleware({
    List<String>? blockedEvents,
    List<String>? allowedEvents,
    bool useAllowlist = false,
  }) : _blockedEvents = blockedEvents ?? [],
       _allowedEvents = allowedEvents ?? [],
       _useAllowlist = useAllowlist;

  @override
  int get priority => 70;

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    // If using allowlist, only track events in the list
    if (_useAllowlist) {
      if (!_allowedEvents.contains(event.name)) {
        return MiddlewareResult.drop;
      }
    }

    // Check if event is blocked
    if (_blockedEvents.contains(event.name)) {
      return MiddlewareResult.drop;
    }

    return MiddlewareResult.continueProcessing;
  }

  /// Add event to blocklist
  void blockEvent(String eventName) {
    if (!_blockedEvents.contains(eventName)) {
      _blockedEvents.add(eventName);
    }
  }

  /// Remove event from blocklist
  void unblockEvent(String eventName) {
    _blockedEvents.remove(eventName);
  }

  /// Add event to allowlist
  void allowEvent(String eventName) {
    if (!_allowedEvents.contains(eventName)) {
      _allowedEvents.add(eventName);
    }
  }
}
