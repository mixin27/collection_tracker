import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:app_analytics/src/storage/consent_storage.dart';

/// Middleware to check user consent before tracking
class ConsentMiddleware implements AnalyticsMiddleware {
  final ConsentStorage _storage;

  ConsentMiddleware({ConsentStorage? storage})
    : _storage = storage ?? ConsentStorage();

  @override
  int get priority => 100; // Run first

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    final hasConsent = await _storage.hasConsent();

    if (!hasConsent) {
      // Drop event if no consent
      return MiddlewareResult.drop;
    }

    return MiddlewareResult.continueProcessing;
  }
}
