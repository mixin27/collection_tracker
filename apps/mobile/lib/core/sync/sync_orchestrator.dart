import 'dart:convert';
import 'dart:math';

import 'package:app_firebase/app_firebase.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:sync_api/sync_api.dart';
import 'package:uuid/uuid.dart';

import 'sync_server_changes_applier.dart';

enum SyncEntityType { collection, item, tag }

enum SyncOperationType { upsert, delete }

class SyncAttemptResult {
  const SyncAttemptResult({
    required this.executed,
    required this.success,
    required this.message,
    this.error,
    this.stackTrace,
    this.pendingOperations = 0,
    this.processedOperations = 0,
    this.syncedCollections = 0,
    this.syncedItems = 0,
    this.syncedTags = 0,
    this.conflictCount = 0,
    this.partial = false,
    this.appliedServerCollections = 0,
    this.appliedServerItems = 0,
    this.appliedServerTags = 0,
    this.skippedServerCollections = 0,
    this.skippedServerItems = 0,
    this.skippedServerTags = 0,
  });

  final bool executed;
  final bool success;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final int pendingOperations;
  final int processedOperations;
  final int syncedCollections;
  final int syncedItems;
  final int syncedTags;
  final int conflictCount;
  final bool partial;
  final int appliedServerCollections;
  final int appliedServerItems;
  final int appliedServerTags;
  final int skippedServerCollections;
  final int skippedServerItems;
  final int skippedServerTags;
}

class SyncOrchestrator {
  SyncOrchestrator({
    required SyncDao syncDao,
    required SyncBackendClient backendClient,
    required SyncServerChangesApplier serverChangesApplier,
    Uuid? uuid,
    int maxBatchSize = 1000,
    int maxNetworkRetries = 2,
    Duration initialRetryDelay = const Duration(milliseconds: 600),
    Random? random,
  }) : _syncDao = syncDao,
       _backendClient = backendClient,
       _serverChangesApplier = serverChangesApplier,
       _uuid = uuid ?? const Uuid(),
       _maxBatchSize = maxBatchSize,
       _maxNetworkRetries = maxNetworkRetries,
       _initialRetryDelay = initialRetryDelay,
       _random = random ?? Random.secure();

  final SyncDao _syncDao;
  final SyncBackendClient _backendClient;
  final SyncServerChangesApplier _serverChangesApplier;
  final Uuid _uuid;
  final int _maxBatchSize;
  final int _maxNetworkRetries;
  final Duration _initialRetryDelay;
  final Random _random;

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
    final pending = await _syncDao.getPendingOperations(limit: _maxBatchSize);

    if (_backendClient is NoopSyncBackendClient) {
      final client = _backendClient;
      return SyncAttemptResult(
        executed: false,
        success: false,
        message: client.message,
        pendingOperations: pending.length,
        partial: false,
      );
    }

    final state = await _syncDao.getSyncState();

    await _syncDao.upsertSyncState(lastAttemptedSyncAt: DateTime.now());

    final changes = _buildChangesPayload(pending);
    final performanceService = FirebasePerformanceService.instance;
    final requestPayload = SyncRequestPayload(
      deviceId: deviceId,
      clientRequestId: _uuid.v4(),
      lastSyncAt: forceFullSync ? null : state?.lastSuccessfulSyncAt,
      changes: changes.isEmpty ? null : changes,
    );

    try {
      final response = await _syncWithRetry(
        request: requestPayload,
        pendingOperationCount: pending.length,
        forceFullSync: forceFullSync,
        performanceService: performanceService,
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
          stackTrace: null,
          pendingOperations: pending.length,
          processedOperations: processedOperations,
          syncedCollections: response.syncedCollections,
          syncedItems: response.syncedItems,
          syncedTags: response.syncedTags,
          conflictCount: response.conflicts.length,
          partial: true,
        );
      }

      final applyResult = await _serverChangesApplier.apply(
        response.serverChanges,
      );

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
            '${response.syncedItems} items, ${response.syncedTags} tags. '
            'Applied ${applyResult.appliedTotal} remote change(s).',
        pendingOperations: pending.length,
        processedOperations: processedOperations,
        syncedCollections: response.syncedCollections,
        syncedItems: response.syncedItems,
        syncedTags: response.syncedTags,
        conflictCount: response.conflicts.length,
        partial: false,
        appliedServerCollections: applyResult.appliedCollections,
        appliedServerItems: applyResult.appliedItems,
        appliedServerTags: applyResult.appliedTags,
        skippedServerCollections: applyResult.skippedCollections,
        skippedServerItems: applyResult.skippedItems,
        skippedServerTags: applyResult.skippedTags,
      );
    } on SyncAuthRequiredException catch (error) {
      return SyncAttemptResult(
        executed: false,
        success: false,
        message: error.message,
        error: error,
        stackTrace: null,
        pendingOperations: pending.length,
        partial: false,
      );
    } on DioException catch (error, stackTrace) {
      final errorText = _buildDioErrorMessage(error);
      for (final op in pending) {
        await _syncDao.markOperationFailed(op.id, errorText);
      }

      await _syncDao.upsertSyncState(
        consecutiveFailures: (state?.consecutiveFailures ?? 0) + 1,
      );

      return SyncAttemptResult(
        executed: true,
        success: false,
        message: errorText,
        error: error,
        stackTrace: stackTrace,
        pendingOperations: pending.length,
        partial: false,
      );
    } catch (error, stackTrace) {
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
        stackTrace: stackTrace,
        pendingOperations: pending.length,
        partial: false,
      );
    }
  }

  String _buildDioErrorMessage(DioException error) {
    final uri = error.requestOptions.uri;
    final host = uri.host;
    final statusCode = error.response?.statusCode;
    final statusMessage = error.response?.statusMessage;

    if (error.type == DioExceptionType.badResponse && statusCode != null) {
      final details = statusMessage == null || statusMessage.isEmpty
          ? ''
          : ' ($statusMessage)';
      return 'Sync failed with HTTP $statusCode$details.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Sync request timed out while contacting $host. '
          'Check backend availability and network.';
    }

    if (error.type == DioExceptionType.connectionError) {
      final localhostHint = host == 'localhost' || host == '127.0.0.1'
          ? ' If this is a physical device, use your computer LAN IP instead of localhost. '
                'For Android emulator use 10.0.2.2.'
          : '';
      return 'Unable to reach sync backend at ${uri.toString()}.$localhostHint';
    }

    if (error.type == DioExceptionType.cancel) {
      return 'Sync request was cancelled.';
    }

    final message = error.message;
    if (message != null && message.trim().isNotEmpty) {
      return 'Sync request failed: $message';
    }

    return 'Sync request failed due to an unexpected network error.';
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

  Future<SyncResponsePayload> _syncWithRetry({
    required SyncRequestPayload request,
    required int pendingOperationCount,
    required bool forceFullSync,
    required FirebasePerformanceService performanceService,
  }) async {
    DioException? lastDioError;

    for (var attempt = 0; attempt <= _maxNetworkRetries; attempt++) {
      try {
        return await performanceService.traceAsync(
          'sync_push_pull_now',
          () => _backendClient.sync(request),
          attributes: {
            'force_full_sync': forceFullSync ? '1' : '0',
            'pending_operations': '$pendingOperationCount',
            'attempt': '${attempt + 1}',
          },
        );
      } on DioException catch (error) {
        lastDioError = error;
        if (!_isRetryableNetworkError(error) || attempt >= _maxNetworkRetries) {
          rethrow;
        }
        await Future<void>.delayed(_retryDelayForAttempt(attempt));
      }
    }

    throw lastDioError ??
        DioException(
          requestOptions: RequestOptions(path: '/sync'),
          type: DioExceptionType.unknown,
          message: 'Sync request failed after retry attempts.',
        );
  }

  bool _isRetryableNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == null) {
          return false;
        }
        return statusCode == 408 ||
            statusCode == 429 ||
            statusCode == 500 ||
            statusCode == 502 ||
            statusCode == 503 ||
            statusCode == 504;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
      case DioExceptionType.unknown:
        return true;
    }
  }

  Duration _retryDelayForAttempt(int attempt) {
    final exponentialMultiplier = 1 << attempt;
    final baseMillis =
        _initialRetryDelay.inMilliseconds * exponentialMultiplier;
    final jitterMillis = _random.nextInt(250);
    return Duration(milliseconds: baseMillis + jitterMillis);
  }
}
