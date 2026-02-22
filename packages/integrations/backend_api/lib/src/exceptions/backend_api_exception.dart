class BackendApiException implements Exception {
  const BackendApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.raw,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? raw;

  @override
  String toString() {
    final status = statusCode != null ? ' [$statusCode]' : '';
    final errorCode = code != null ? ' <$code>' : '';
    return 'BackendApiException$status$errorCode: $message';
  }
}
