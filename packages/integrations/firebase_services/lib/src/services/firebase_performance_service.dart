import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class FirebasePerformanceService {
  FirebasePerformanceService._({FirebasePerformance? performance})
    : _performance = performance ?? FirebasePerformance.instance;

  static FirebasePerformanceService? _instance;

  static FirebasePerformanceService get instance {
    _instance ??= FirebasePerformanceService._();
    return _instance!;
  }

  final FirebasePerformance _performance;

  bool _initialized = false;
  bool _collectionEnabled = false;

  bool get isInitialized => _initialized;
  bool get isCollectionEnabled => _collectionEnabled;

  Future<void> initialize({required bool enabled}) async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      _collectionEnabled = enabled;
      _initialized = true;
    } catch (error) {
      _collectionEnabled = false;
      _initialized = false;
      if (kDebugMode) {
        debugPrint('FirebasePerformance initialize failed: $error');
      }
    }
  }

  Future<void> setCollectionEnabled(bool enabled) async {
    if (!_initialized || Firebase.apps.isEmpty) {
      _collectionEnabled = enabled;
      return;
    }

    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      _collectionEnabled = enabled;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FirebasePerformance setCollectionEnabled failed: $error');
      }
    }
  }

  Future<Trace?> startTrace(
    String traceName, {
    Map<String, String>? attributes,
  }) async {
    if (!_isReady) {
      if (kDebugMode) {
        debugPrint(
          'Skipping Firebase trace $traceName: initialized=$_initialized, '
          'collectionEnabled=$_collectionEnabled',
        );
      }
      return null;
    }

    try {
      final trace = _performance.newTrace(traceName);
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }
      await trace.start();
      return trace;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to start Firebase trace $traceName: $error');
      }
      return null;
    }
  }

  Future<void> stopTrace(Trace? trace, {Map<String, int>? metrics}) async {
    if (trace == null) {
      return;
    }

    if (metrics != null) {
      for (final entry in metrics.entries) {
        trace.setMetric(entry.key, entry.value);
      }
    }

    try {
      await trace.stop();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to stop Firebase trace: $error');
      }
    }
  }

  Future<T> traceAsync<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    bool trackErrorMetric = true,
  }) async {
    final trace = await startTrace(traceName, attributes: attributes);
    var hasError = false;

    try {
      return await operation();
    } catch (error) {
      hasError = true;
      rethrow;
    } finally {
      if (trackErrorMetric && trace != null) {
        trace.setMetric('failed', hasError ? 1 : 0);
      }
      await stopTrace(trace);
    }
  }

  HttpMetric? newHttpMetric(String url, HttpMethod method) {
    if (!_isReady) {
      if (kDebugMode) {
        debugPrint(
          'Skipping Firebase HttpMetric for $url: initialized=$_initialized, '
          'collectionEnabled=$_collectionEnabled',
        );
      }
      return null;
    }

    try {
      return _performance.newHttpMetric(url, method);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to create Firebase HttpMetric for $url: $error');
      }
      return null;
    }
  }

  bool get _isReady => _initialized && _collectionEnabled;
}
