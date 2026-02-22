import 'dart:convert';

import 'package:database/database.dart';
import 'package:sync_api/sync_api.dart';
import 'package:uuid/uuid.dart';

enum SyncEntityType { collection, item, tag }

enum SyncOperationType { upsert, delete }

class SyncAttemptResult {
  const SyncAttemptResult({
    required this.executed,
    required this.success,
    required this.message,
    this.error,
  });

  final bool executed;
  final bool success;
  final String message;
  final Object? error;
}

class SyncOrchestrator {
  SyncOrchestrator({
    required SyncDao syncDao,
    required SyncBackendClient backendClient,
    Uuid? uuid,
    int maxBatchSize = 1000,
  }) : _syncDao = syncDao,
       _backendClient = backendClient,
       _uuid = uuid ?? const Uuid(),
       _maxBatchSize = maxBatchSize;

  final SyncDao _syncDao;
  final SyncBackendClient _backendClient;
  final Uuid _uuid;
  final int _maxBatchSize;

  Stream<int> watchPendingOperationCount() {
    return _syncDao.watchPendingOperationCount();
  }

  Future<int> getPendingOperationCount() async {
    final pending = await _syncDao.getPendingOperations(limit: _maxBatchSize);
    return pending.length;
  }

  Future<String> enqueueOperation({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> payload,
    String? operationId,
  }) async {
    final id = operationId ?? _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();

    final normalizedPayload = <String, dynamic>{
      ...payload,
      'id': payload['id'] ?? entityId,
      'updatedAt': payload['updatedAt'] ?? now,
      'isDeleted': operationType == SyncOperationType.delete,
    };

    await _syncDao.enqueueOperation(
      id: id,
      entityType: entityType.name,
      entityId: entityId,
      operationType: operationType.name,
      payload: jsonEncode(normalizedPayload),
    );

    return id;
  }

  Future<SyncAttemptResult> syncNow({
    required String deviceId,
    bool forceFullSync = false,
  }) async {
    if (_backendClient is NoopSyncBackendClient) {
      final client = _backendClient;
      return SyncAttemptResult(
        executed: false,
        success: false,
        message: client.message,
      );
    }

    final state = await _syncDao.getSyncState();
    final pending = await _syncDao.getPendingOperations(limit: _maxBatchSize);

    await _syncDao.upsertSyncState(lastAttemptedSyncAt: DateTime.now());

    if (pending.isEmpty && !forceFullSync) {
      await _syncDao.upsertSyncState(consecutiveFailures: 0);
      return const SyncAttemptResult(
        executed: false,
        success: true,
        message: 'No pending operations to sync.',
      );
    }

    final changes = _buildChangesPayload(pending);

    try {
      final response = await _backendClient.sync(
        SyncRequestPayload(
          deviceId: deviceId,
          clientRequestId: _uuid.v4(),
          lastSyncAt: forceFullSync ? null : state?.lastSuccessfulSyncAt,
          changes: changes.isEmpty ? null : changes,
        ),
      );

      final processedOperations = _processedOperationCount(response);
      if (processedOperations < pending.length) {
        final errorText =
            'Sync response did not process all operations '
            '(processed: $processedOperations, pending: ${pending.length}).';

        for (final op in pending) {
          await _syncDao.markOperationFailed(op.id, errorText);
        }

        await _syncDao.upsertSyncState(
          consecutiveFailures: (state?.consecutiveFailures ?? 0) + 1,
        );

        return SyncAttemptResult(
          executed: true,
          success: false,
          message:
              'Sync partially processed. Local queue kept for retry. '
              'Processed $processedOperations of ${pending.length} change(s).',
          error: errorText,
        );
      }

      for (final op in pending) {
        await _syncDao.markOperationSynced(op.id);
      }

      await _syncDao.upsertSyncState(
        lastSuccessfulSyncAt: response.lastSyncAt.toUtc(),
        consecutiveFailures: 0,
      );

      return SyncAttemptResult(
        executed: true,
        success: true,
        message:
            'Sync completed: ${response.syncedCollections} collections, '
            '${response.syncedItems} items, ${response.syncedTags} tags.',
      );
    } on SyncAuthRequiredException catch (error) {
      return SyncAttemptResult(
        executed: false,
        success: false,
        message: error.message,
        error: error,
      );
    } catch (error) {
      final errorText = '$error';
      for (final op in pending) {
        await _syncDao.markOperationFailed(op.id, errorText);
      }

      await _syncDao.upsertSyncState(
        consecutiveFailures: (state?.consecutiveFailures ?? 0) + 1,
      );

      return SyncAttemptResult(
        executed: true,
        success: false,
        message: 'Sync failed.',
        error: error,
      );
    }
  }

  SyncChangesPayload _buildChangesPayload(List<SyncOutboxData> pending) {
    final collections = <Map<String, dynamic>>[];
    final items = <Map<String, dynamic>>[];
    final tags = <Map<String, dynamic>>[];

    for (final op in pending) {
      final decoded = jsonDecode(op.payload);
      if (decoded is! Map) {
        continue;
      }

      final payload = decoded.cast<String, dynamic>();
      if (op.entityType == SyncEntityType.collection.name) {
        collections.add(payload);
      } else if (op.entityType == SyncEntityType.item.name) {
        items.add(payload);
      } else if (op.entityType == SyncEntityType.tag.name) {
        tags.add(payload);
      }
    }

    return SyncChangesPayload(
      collections: collections,
      items: items,
      tags: tags,
    );
  }

  int _processedOperationCount(SyncResponsePayload response) {
    return response.syncedCollections +
        response.syncedItems +
        response.syncedTags +
        response.conflicts.length;
  }
}
