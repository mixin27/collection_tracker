/// Base exception for analytics errors
class AnalyticsException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AnalyticsException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AnalyticsException: $message${code != null ? ' ($code)' : ''}';
}

class AnalyticsInitializationException extends AnalyticsException {
  const AnalyticsInitializationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class AnalyticsConsentException extends AnalyticsException {
  const AnalyticsConsentException(
    super.message, {
    super.code,
    super.originalError,
  });
}
