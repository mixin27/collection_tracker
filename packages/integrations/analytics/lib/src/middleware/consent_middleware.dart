import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:app_analytics/src/core/analytics_service.dart';
import 'package:app_analytics/src/storage/consent_storage.dart';

typedef ConsentResolver = Future<bool> Function();

/// Middleware to check user consent before tracking
class ConsentMiddleware implements AnalyticsMiddleware {
  final ConsentStorage _storage;
  final ConsentResolver? _consentResolver;
  final bool _preferServiceState;

  ConsentMiddleware({ConsentStorage? storage, ConsentResolver? consentResolver})
    : _storage = storage ?? ConsentStorage(),
      _consentResolver = consentResolver,
      _preferServiceState = storage == null && consentResolver == null;

  @override
  int get priority => 100; // Run first

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    final hasConsent = await _resolveConsent();

    if (!hasConsent) {
      // Drop event if no consent
      return MiddlewareResult.drop;
    }

    return MiddlewareResult.continueProcessing;
  }

  Future<bool> _resolveConsent() async {
    final consentResolver = _consentResolver;
    if (consentResolver != null) {
      return consentResolver();
    }

    if (_preferServiceState && AnalyticsService.instance.isInitialized) {
      return AnalyticsService.instance.hasConsent;
    }

    return _storage.hasConsent();
  }
}
