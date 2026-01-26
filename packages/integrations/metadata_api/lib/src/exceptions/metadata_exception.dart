/// Additional exception types specific to metadata fetching
class MetadataException implements Exception {
  final String message;
  final String? code;

  const MetadataException(this.message, {this.code});

  @override
  String toString() =>
      'MetadataException: $message${code != null ? ' ($code)' : ''}';
}

class MetadataNotFoundException extends MetadataException {
  const MetadataNotFoundException(super.message) : super(code: 'NOT_FOUND');
}

class MetadataQuotaExceededException extends MetadataException {
  const MetadataQuotaExceededException(super.message)
    : super(code: 'QUOTA_EXCEEDED');
}

class MetadataAuthException extends MetadataException {
  const MetadataAuthException(super.message) : super(code: 'AUTH_FAILED');
}
