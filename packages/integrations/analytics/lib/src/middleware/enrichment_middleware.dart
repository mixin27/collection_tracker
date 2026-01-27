import 'dart:io';

import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Middleware to enrich events with common properties
class EnrichmentMiddleware implements AnalyticsMiddleware {
  final Map<String, dynamic> _commonProperties = {};

  EnrichmentMiddleware() {
    _initializeCommonProperties();
  }

  @override
  int get priority => 80;

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
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
    } else if (Platform.isAndroid) {
      _commonProperties['platform'] = 'android';
    } else if (Platform.isIOS) {
      _commonProperties['platform'] = 'ios';
    } else if (Platform.isMacOS) {
      _commonProperties['platform'] = 'macos';
    } else if (Platform.isWindows) {
      _commonProperties['platform'] = 'windows';
    } else if (Platform.isLinux) {
      _commonProperties['platform'] = 'linux';
    }

    // App version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _commonProperties['app_version'] = packageInfo.version;

    // Build mode
    _commonProperties['build_mode'] = kDebugMode ? 'debug' : 'release';
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
