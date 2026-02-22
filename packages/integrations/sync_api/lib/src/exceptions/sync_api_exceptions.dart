class SyncApiException implements Exception {
  const SyncApiException(this.message);

  final String message;

  @override
  String toString() => 'SyncApiException: $message';
}

class SyncAuthRequiredException extends SyncApiException {
  const SyncAuthRequiredException({
    String message =
        'Authentication is required for sync. Sign in to use sync features.',
  }) : super(message);
}
