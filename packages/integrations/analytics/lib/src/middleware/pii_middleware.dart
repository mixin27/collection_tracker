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

  final RegExp _phoneRegex = RegExp(
    r'^\+?(\d[\d-. ]+)?(\([\d-. ]+\))?[\d-. ]+\d$',
  );

  final RegExp _creditCardRegex = RegExp(r'\b(?:\d[ -]*?){13,16}\b');

  final RegExp _ssnRegex = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');

  final RegExp _ipv4Regex = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b');

  final RegExp _ipv6Regex = RegExp(r'([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}');

  final RegExp _dateRegex = RegExp(
    r'^\d{4}-\d{2}-\d{2}$|^\d{1,2}/\d{1,2}/\d{4}$',
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

    // Check if value looks like a phone number (min 7 digits)
    // Avoid short numbers/integers being flagged
    if (value.length >= 7 &&
        value.length <= 15 &&
        _phoneRegex.hasMatch(value) &&
        // Ensure it has at least 7 digits
        value.replaceAll(RegExp(r'[^0-9]'), '').length >= 7) {
      return true;
    }

    // Check credit card
    if (_creditCardRegex.hasMatch(value)) {
      return true;
    }

    // Check SSN
    if (_ssnRegex.hasMatch(value)) {
      return true;
    }

    // Check IP
    if (_ipv4Regex.hasMatch(value) || _ipv6Regex.hasMatch(value)) {
      return true;
    }

    // Check Date
    if (_dateRegex.hasMatch(value)) {
      return true;
    }

    return false;
  }

  /// Add a custom PII key to filter
  void addPIIKey(String key) {
    if (!_piiKeys.contains(key)) {
      _piiKeys.add(key);
    }
  }
}
