import 'dart:convert';

import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage for analytics event queue
class AnalyticsStorage {
  static const _queueKey = 'analytics_event_queue';
  static const _maxQueueSize = 100;

  /// Get queued events
  Future<List<AnalyticsEvent>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_queueKey) ?? [];

    return jsonList
        .map((json) => AnalyticsEvent.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Save event queue
  Future<void> saveQueue(List<AnalyticsEvent> events) async {
    final prefs = await SharedPreferences.getInstance();

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Add event to queue
  Future<void> addToQueue(AnalyticsEvent event) async {
    final queue = await getQueue();
    queue.add(event);
    await saveQueue(queue);
  }
}
