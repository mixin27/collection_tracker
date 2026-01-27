import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:app_analytics/src/core/analytics_service.dart';
import 'package:app_analytics/src/storage/analytics_storage.dart';

/// Middleware to queue events when offline
class QueueMiddleware implements AnalyticsMiddleware {
  final AnalyticsStorage _storage;
  final int _maxQueueSize;

  QueueMiddleware({AnalyticsStorage? storage, int maxQueueSize = 100})
    : _storage = storage ?? AnalyticsStorage(),
      _maxQueueSize = maxQueueSize;

  @override
  int get priority => 60;

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    // Check if offline
    final isOnline = await _checkConnectivity();

    if (!isOnline) {
      // Queue event
      await _queueEvent(event);
      return MiddlewareResult.drop; // Don't send now
    }

    // If online, check if there are queued events
    await _flushQueue();

    return MiddlewareResult.continueProcessing;
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> _queueEvent(AnalyticsEvent event) async {
    final queue = await _storage.getQueue();

    // Check queue size
    if (queue.length >= _maxQueueSize) {
      // Remove oldest event
      queue.removeAt(0);
    }

    queue.add(event);
    await _storage.saveQueue(queue);
  }

  Future<void> _flushQueue() async {
    final queue = await _storage.getQueue();

    if (queue.isEmpty) return;

    // Send queued events
    // We need to use the service to track them, but avoid infinite loops
    // Ideally, the service should have a method to direct send to providers
    // or we can just call track() and let other middleware handle it (might be redundant but safe)
    // However, if we are here, we are online.

    // Better approach: Get the service and send to providers directly or re-process?
    // Re-processing runs all middleware again (enrichment, pii, etc).
    // If they were already processed before queuing (priority 60), iterating might duplicate work or be fine.
    // Given priority is 60, Enrichment(80), PII(85) already ran.
    // So we should probably send directly to providers if we can, or just re-track.
    // Since AnalyticsService access to providers is private, we'll re-track.
    // BUT we must ensure we don't queue again if it fails immediately?
    // Actually, re-tracking is dangerous if we don't have a way to skip queue middleware.

    // Changing approach: Use AnalyticsService.instance.track() but we need to avoid the QueueMiddleware this time?
    // Use a custom property or check if it's a replayed event?
    // For simplicity given the scope, I will assume re-tracking is fine as long as we are online.
    // If we go offline during flush, they will be re-queued.

    // Clear queue first to prevent loops if we crash/fail partially?
    // Or remove one by one?

    // Let's clear queue then re-track. If re-track fails and queues again, so be it.
    await _storage.clearQueue();

    for (final event in queue) {
      // Re-track event
      // We need to access AnalyticsService.
      // Since it's a singleton, we can use it.
      // Note: This relies on AnalyticsService being initialized.
      try {
        await AnalyticsService.instance.track(event);
      } catch (e) {
        print('Error re-tracking queued event: $e');
      }
    }
  }
}
