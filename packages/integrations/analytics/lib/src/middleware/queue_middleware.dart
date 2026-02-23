import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:app_analytics/src/core/analytics_service.dart';
import 'package:app_analytics/src/storage/analytics_storage.dart';

/// Middleware to queue events when offline
class QueueMiddleware implements AnalyticsMiddleware {
  final AnalyticsStorage? _storageOverride;

  QueueMiddleware({AnalyticsStorage? storage, int maxQueueSize = 100})
    : _storageOverride =
          storage ??
          (maxQueueSize == 100
              ? null
              : AnalyticsStorage(maxQueueSize: maxQueueSize));

  @override
  int get priority => 60;

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    final service = AnalyticsService.instance;
    if (!service.isOfflineQueueEnabled) {
      return MiddlewareResult.continueProcessing;
    }

    final isOnline = await service.isOnline();

    if (!isOnline) {
      await service.queueEvent(event, storage: _storageOverride);
      return MiddlewareResult.drop;
    }

    await service.flushQueuedEvents(storage: _storageOverride);

    return MiddlewareResult.continueProcessing;
  }
}
