import 'package:freezed_annotation/freezed_annotation.dart';

import 'analytics_middleware.dart';
import 'analytics_provider.dart';

part 'analytics_config.freezed.dart';

/// Analytics environment
enum AnalyticsEnvironment { development, staging, production }

/// Configuration for analytics service
@freezed
abstract class AnalyticsConfig with _$AnalyticsConfig {
  const factory AnalyticsConfig({
    /// Environment (dev, staging, prod)
    @Default(AnalyticsEnvironment.development) AnalyticsEnvironment environment,

    /// List of analytics providers to use
    @Default([]) List<AnalyticsProvider> providers,

    /// Middleware to process events
    @Default([]) List<AnalyticsMiddleware> middleware,

    /// Enable debug logging
    @Default(false) bool enableLogging,

    /// Automatically track screen views
    @Default(true) bool autoTrackScreenViews,

    /// Automatically track app lifecycle events
    @Default(true) bool autoTrackAppLifecycle,

    /// Maximum events to queue when offline
    @Default(100) int maxQueueSize,

    /// Flush queue interval (seconds)
    @Default(30) int flushInterval,

    /// Enable offline event queueing
    @Default(true) bool enableOfflineQueue,

    /// Common properties added to all events
    @Default({}) Map<String, dynamic> commonProperties,

    /// Session timeout (minutes)
    @Default(30) int sessionTimeout,

    /// Enable consent management
    @Default(true) bool requireConsent,
  }) = _AnalyticsConfig;

  const AnalyticsConfig._();

  /// Check if running in production
  bool get isProduction => environment == AnalyticsEnvironment.production;

  /// Check if running in development
  bool get isDevelopment => environment == AnalyticsEnvironment.development;
}
