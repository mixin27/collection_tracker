import 'dart:convert';

import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage for analytics event queue
class AnalyticsStorage {
  static const _defaultQueueKey = 'analytics_event_queue';

  AnalyticsStorage({
    int maxQueueSize = 100,
    String queueKey = _defaultQueueKey,
    SharedPreferences? sharedPreferences,
  }) : _maxQueueSize = maxQueueSize,
       _queueKey = queueKey,
       _sharedPreferences = sharedPreferences;

  final int _maxQueueSize;
  final String _queueKey;
  final SharedPreferences? _sharedPreferences;

  /// Get queued events
  Future<List<AnalyticsEvent>> getQueue() async {
    final prefs = await _getPrefs();
    final jsonList = prefs.getStringList(_queueKey) ?? [];

    final events = <AnalyticsEvent>[];

    for (final jsonValue in jsonList) {
      try {
        final decoded = jsonDecode(jsonValue);
        if (decoded is Map<String, dynamic>) {
          events.add(AnalyticsEvent.fromJson(decoded));
        } else if (decoded is Map) {
          events.add(
            AnalyticsEvent.fromJson(Map<String, dynamic>.from(decoded)),
          );
        }
      } catch (_) {
        // Skip malformed entries to keep queue usable.
      }
    }

    return events;
  }

  /// Save event queue
  Future<void> saveQueue(List<AnalyticsEvent> events) async {
    final prefs = await _getPrefs();

    // Limit queue size
    final limitedEvents = events.length > _maxQueueSize
        ? events.sublist(events.length - _maxQueueSize)
        : events;

    final jsonList = limitedEvents
        .map((event) => jsonEncode(event.toJson()))
        .toList();

    await prefs.setStringList(_queueKey, jsonList);
  }

  /// Clear event queue
  Future<void> clearQueue() async {
    final prefs = await _getPrefs();
    await prefs.remove(_queueKey);
  }

  /// Add event to queue
  Future<void> addToQueue(AnalyticsEvent event) async {
    final queue = await getQueue();
    queue.add(event);
    await saveQueue(queue);
  }

  Future<SharedPreferences> _getPrefs() async {
    final prefs = _sharedPreferences;
    if (prefs != null) {
      return prefs;
    }

    return SharedPreferences.getInstance();
  }
}
