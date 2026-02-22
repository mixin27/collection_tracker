import 'sync_contract.dart';

abstract class SyncBackendClient {
  Future<SyncCapabilities> getCapabilities();
  Future<SyncResponsePayload> sync(SyncRequestPayload request);
}

class NoopSyncBackendClient implements SyncBackendClient {
  const NoopSyncBackendClient();

  @override
  Future<SyncCapabilities> getCapabilities() async {
    throw UnsupportedError(
      'Backend sync is not configured yet. Provide a concrete SyncBackendClient.',
    );
  }

  @override
  Future<SyncResponsePayload> sync(SyncRequestPayload request) async {
    throw UnsupportedError(
      'Backend sync is not configured yet. Provide a concrete SyncBackendClient.',
    );
  }
}
