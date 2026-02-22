import 'dart:convert';

import 'package:app_analytics/app_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:storage/storage.dart';

class OperationalTelemetry {
  const OperationalTelemetry._();

  static const String _historyKey = 'operational_telemetry_history_v1';
  static const int _maxHistoryEntries = 80;

  static Future<void> trackSyncAttempt({
    required String trigger,
    required String readinessStatus,
    required int pendingBefore,
  }) {
    return _trackEvent(
      name: 'sync_attempted',
      category: 'sync',
      properties: {
        'trigger': trigger,
        'readiness_status': readinessStatus,
        'pending_before': pendingBefore,
      },
      crashlyticsLog: true,
    );
  }

  static Future<void> trackSyncSeed({
    required int queuedOperations,
    required bool skipped,
  }) {
    return _trackEvent(
      name: 'sync_seed_prepared',
      category: 'sync',
      properties: {'queued_operations': queuedOperations, 'skipped': skipped},
      crashlyticsLog: true,
    );
  }

  static Future<void> trackSyncResult({
    required bool success,
    required bool executed,
    required bool partial,
    required int pendingOperations,
    required int processedOperations,
    required int syncedCollections,
    required int syncedItems,
    required int syncedTags,
    required int conflictCount,
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _trackEvent(
      name: 'sync_completed',
      category: 'sync',
      properties: {
        'success': success,
        'executed': executed,
        'partial': partial,
        'pending_operations': pendingOperations,
        'processed_operations': processedOperations,
        'synced_collections': syncedCollections,
        'synced_items': syncedItems,
        'synced_tags': syncedTags,
        'conflicts': conflictCount,
        if (message != null && message.trim().isNotEmpty) 'message': message,
      },
      crashlyticsLog: true,
      error: error,
      stackTrace: stackTrace,
      includeErrorInCrashlytics: !success && error != null,
      errorReason: 'sync_completed_failed',
      crashlyticsKeys: {
        'sync_success': success,
        'sync_partial': partial,
        'sync_executed': executed,
        'sync_pending_ops': pendingOperations,
        'sync_processed_ops': processedOperations,
      },
    );
  }

  static Future<void> trackSyncQueueRebuild({
    required bool success,
    required int queuedOperations,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _trackEvent(
      name: 'sync_queue_rebuild',
      category: 'sync',
      properties: {'success': success, 'queued_operations': queuedOperations},
      crashlyticsLog: true,
      error: error,
      stackTrace: stackTrace,
      includeErrorInCrashlytics: !success && error != null,
      errorReason: 'sync_queue_rebuild_failed',
    );
  }

  static Future<void> trackDataTransfer({
    required String operation,
    required bool success,
    required int durationMs,
    int? collectionCount,
    int? itemCount,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _trackEvent(
      name: 'data_transfer_completed',
      category: 'settings_data',
      properties: {
        'operation': operation,
        'success': success,
        'duration_ms': durationMs,
        'collection_count': ?collectionCount,
        'item_count': ?itemCount,
      },
      crashlyticsLog: true,
      error: error,
      stackTrace: stackTrace,
      includeErrorInCrashlytics: !success && error != null,
      errorReason: 'data_transfer_failed',
    );
  }

  static Future<void> trackRuntimeConfigApplied({
    required String source,
    required bool analyticsEnabled,
    required bool crashlyticsEnabled,
    required bool performanceEnabled,
    required bool backendEnabled,
    required bool syncEnabled,
    bool? didActivateChanges,
  }) {
    return _trackEvent(
      name: 'runtime_config_applied',
      category: 'operations',
      properties: {
        'source': source,
        'analytics_enabled': analyticsEnabled,
        'crashlytics_enabled': crashlyticsEnabled,
        'performance_enabled': performanceEnabled,
        'backend_enabled': backendEnabled,
        'sync_enabled': syncEnabled,
        'changed': ?didActivateChanges,
      },
      crashlyticsLog: true,
      crashlyticsKeys: {
        'flag_analytics_enabled': analyticsEnabled,
        'flag_crashlytics_enabled': crashlyticsEnabled,
        'flag_performance_enabled': performanceEnabled,
        'flag_backend_enabled': backendEnabled,
        'flag_sync_enabled': syncEnabled,
      },
    );
  }

  static Future<void> _trackEvent({
    required String name,
    required String category,
    required Map<String, dynamic> properties,
    required bool crashlyticsLog,
    Map<String, Object?>? crashlyticsKeys,
    Object? error,
    StackTrace? stackTrace,
    bool includeErrorInCrashlytics = false,
    String? errorReason,
  }) async {
    final cleanedProperties = _compact(properties);

    try {
      await AnalyticsService.instance.track(
        AnalyticsEvent.custom(
          name: name,
          category: category,
          properties: cleanedProperties,
        ),
      );
    } catch (_) {
      // Keep operational telemetry best-effort.
    }

    if (!_canUseCrashlytics) {
      return;
    }

    try {
      if (crashlyticsKeys != null) {
        for (final entry in crashlyticsKeys.entries) {
          final value = entry.value;
          if (value is bool ||
              value is int ||
              value is double ||
              value is String) {
            await FirebaseCrashlytics.instance.setCustomKey(
              entry.key,
              value as Object,
            );
          } else if (value != null) {
            await FirebaseCrashlytics.instance.setCustomKey(
              entry.key,
              value.toString(),
            );
          }
        }
      }

      if (crashlyticsLog) {
        await FirebaseCrashlytics.instance.log(
          '$name ${jsonEncode(_stringifyValues(cleanedProperties))}',
        );
      }

      if (includeErrorInCrashlytics && error != null) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: false,
          reason: errorReason ?? name,
          information: [cleanedProperties],
        );
      }
    } catch (_) {
      // Keep operational telemetry best-effort.
    }

    await _persistEvent(
      name: name,
      category: category,
      properties: cleanedProperties,
      hasError: error != null,
    );
  }

  static Future<List<Map<String, dynamic>>> loadRecentHistory({
    int limit = 40,
  }) async {
    try {
      final raw = await PrefsStorageService.instance.get<List<dynamic>>(
        _historyKey,
      );
      if (raw == null || raw.isEmpty) {
        return const <Map<String, dynamic>>[];
      }

      final decoded = raw
          .whereType<Map>()
          .map((entry) => entry.cast<String, dynamic>())
          .toList(growable: false);
      if (decoded.length <= limit) {
        return decoded;
      }
      return decoded.take(limit).toList(growable: false);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  static Future<void> clearHistory() async {
    try {
      await PrefsStorageService.instance.delete(_historyKey);
    } catch (_) {
      // Keep operational telemetry best-effort.
    }
  }

  static Map<String, dynamic> _compact(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    for (final entry in source.entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  static Map<String, String> _stringifyValues(Map<String, dynamic> source) {
    final result = <String, String>{};
    for (final entry in source.entries) {
      result[entry.key] = '${entry.value}';
    }
    return result;
  }

  static bool get _canUseCrashlytics => !kIsWeb && Firebase.apps.isNotEmpty;

  static Future<void> _persistEvent({
    required String name,
    required String category,
    required Map<String, dynamic> properties,
    required bool hasError,
  }) async {
    try {
      final existing = await loadRecentHistory(limit: _maxHistoryEntries);
      final next = <Map<String, dynamic>>[
        {
          'name': name,
          'category': category,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'has_error': hasError,
          'properties': _stringifyValues(properties),
        },
        ...existing,
      ];

      if (next.length > _maxHistoryEntries) {
        next.removeRange(_maxHistoryEntries, next.length);
      }

      await PrefsStorageService.instance.save<List<dynamic>>(_historyKey, next);
    } catch (_) {
      // Keep operational telemetry best-effort.
    }
  }
}
