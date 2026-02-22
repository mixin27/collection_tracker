import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Middleware to enrich events with common properties
class EnrichmentMiddleware implements AnalyticsMiddleware {
  final Map<String, dynamic> _commonProperties = {};
  late final Future<void> _initialization;

  EnrichmentMiddleware() {
    _initialization = _initializeCommonProperties();
  }

  @override
  int get priority => 80;

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    await _initialization;

    // Add common properties to event
    final enrichedEvent = event.withProperties(_commonProperties);

    // Continue with enriched event
    next(enrichedEvent);
    return MiddlewareResult.continueProcessing;
  }

  Future<void> _initializeCommonProperties() async {
    // Platform
    if (kIsWeb) {
      _commonProperties['platform'] = 'web';
    } else {
      _commonProperties['platform'] = switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        TargetPlatform.macOS => 'macos',
        TargetPlatform.windows => 'windows',
        TargetPlatform.linux => 'linux',
        TargetPlatform.fuchsia => 'fuchsia',
      };
    }

    // App version may be unavailable in tests or unsupported environments.
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _commonProperties['app_version'] = packageInfo.version;
      _commonProperties['app_build_number'] = packageInfo.buildNumber;
    } catch (_) {
      // Ignore package info failures to keep middleware non-blocking.
    }

    // Build mode
    _commonProperties['build_mode'] = kDebugMode
        ? 'debug'
        : (kProfileMode ? 'profile' : 'release');
  }

  /// Add or update a common property
  void setCommonProperty(String key, dynamic value) {
    _commonProperties[key] = value;
  }

  /// Remove a common property
  void removeCommonProperty(String key) {
    _commonProperties.remove(key);
  }
}
