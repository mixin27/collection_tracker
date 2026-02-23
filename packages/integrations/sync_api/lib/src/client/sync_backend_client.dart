import '../models/sync_contract.dart';

enum SyncBackendUnavailableReason {
  notConfigured,
  featureFlagDisabled,
  unknown,
}

abstract class SyncBackendClient {
  Future<SyncCapabilities> getCapabilities();
  Future<SyncResponsePayload> sync(SyncRequestPayload request);
}

class NoopSyncBackendClient implements SyncBackendClient {
  const NoopSyncBackendClient({
    this.reason = SyncBackendUnavailableReason.notConfigured,
    String? message,
  }) : _message = message;

  final SyncBackendUnavailableReason reason;
  final String? _message;

  String get message {
    if (_message != null && _message.trim().isNotEmpty) {
      return _message;
    }

    return switch (reason) {
      SyncBackendUnavailableReason.featureFlagDisabled =>
        'Sync is disabled by runtime feature flag.',
      SyncBackendUnavailableReason.notConfigured =>
        'Sync backend is not configured yet. Provide a concrete SyncBackendClient.',
      SyncBackendUnavailableReason.unknown =>
        'Sync backend is currently unavailable.',
    };
  }

  @override
  Future<SyncCapabilities> getCapabilities() async {
    throw UnsupportedError(message);
  }

  @override
  Future<SyncResponsePayload> sync(SyncRequestPayload request) async {
    throw UnsupportedError(message);
  }
}
