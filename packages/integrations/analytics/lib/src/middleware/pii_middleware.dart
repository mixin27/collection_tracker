import 'package:app_analytics/src/core/analytics_event.dart';
import 'package:app_analytics/src/core/analytics_middleware.dart';

/// Middleware to filter out Personally Identifiable Information (PII)
class PIIFilterMiddleware implements AnalyticsMiddleware {
  final List<String> _piiKeys = [
    'email',
    'phone',
    'ssn',
    'credit_card',
    'password',
    'address',
    'full_name',
  ];

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  int get priority => 85; // Run before most middleware

  @override
  Future<MiddlewareResult> process(
    AnalyticsEvent event, {
    required bool Function(AnalyticsEvent) next,
  }) async {
    final filteredProperties = <String, dynamic>{};

    for (final entry in event.properties.entries) {
      // Check if key is a PII key
      if (_isPIIKey(entry.key)) {
        // Replace with [REDACTED]
        filteredProperties[entry.key] = '[REDACTED]';
        continue;
      }

      // Check if value looks like PII
      if (entry.value is String && _isPIIValue(entry.value as String)) {
        filteredProperties[entry.key] = '[REDACTED]';
        continue;
      }

      filteredProperties[entry.key] = entry.value;
    }

    final filteredEvent = event.copyWith(properties: filteredProperties);
    next(filteredEvent);
    return MiddlewareResult.continueProcessing;
  }

  bool _isPIIKey(String key) {
    final lowerKey = key.toLowerCase();
    return _piiKeys.any((pii) => lowerKey.contains(pii));
  }

  bool _isPIIValue(String value) {
    // Check if value looks like an email
    if (_emailRegex.hasMatch(value)) {
      return true;
    }

    // Add more PII detection logic here
    // - Phone numbers
    // - Credit cards
    // - SSN
    // etc.

    return false;
  }

  /// Add a custom PII key to filter
  void addPIIKey(String key) {
    if (!_piiKeys.contains(key)) {
      _piiKeys.add(key);
    }
  }
}
