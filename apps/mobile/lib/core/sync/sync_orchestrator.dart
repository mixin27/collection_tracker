import 'dart:convert';
import 'dart:math';

import 'package:app_firebase/app_firebase.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:sync_api/sync_api.dart';
import 'package:uuid/uuid.dart';

import 'sync_server_changes_applier.dart';

typedef SyncTraceRunner =
    Future<T> Function<T>(
      String traceName,
      Future<T> Function() operation, {
      Map<String, String>? attributes,
    });

enum SyncEntityType { collection, item, tag, loan }

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
    this.syncedLoans = 0,
    this.conflictCount = 0,
    this.partial = false,
    this.appliedServerCollections = 0,
    this.appliedServerItems = 0,
    this.appliedServerTags = 0,
    this.appliedServerLoans = 0,
    this.skippedServerCollections = 0,
    this.skippedServerItems = 0,
    this.skippedServerTags = 0,
    this.skippedServerLoans = 0,
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
  final int syncedLoans;
  final int conflictCount;
  final bool partial;
  final int appliedServerCollections;
  final int appliedServerItems;
  final int appliedServerTags;
  final int appliedServerLoans;
  final int skippedServerCollections;
  final int skippedServerItems;
  final int skippedServerTags;
  final int skippedServerLoans;
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
    Duration scheduledRetryBaseDelay = const Duration(seconds: 15),
    Duration maxScheduledRetryDelay = const Duration(minutes: 10),
    SyncTraceRunner? traceRunner,
    Random? random,
  }) : _syncDao = syncDao,
       _backendClient = backendClient,
       _serverChangesApplier = serverChangesApplier,
       _uuid = uuid ?? const Uuid(),
       _maxBatchSize = maxBatchSize,
       _maxNetworkRetries = maxNetworkRetries,
       _initialRetryDelay = initialRetryDelay,
       _scheduledRetryBaseDelay = scheduledRetryBaseDelay,
       _maxScheduledRetryDelay = maxScheduledRetryDelay,
       _traceRunner = traceRunner ?? _defaultTraceRunner,
       _random = random ?? Random.secure();

  final SyncDao _syncDao;
  final SyncBackendClient _backendClient;
  final SyncServerChangesApplier _serverChangesApplier;
  final Uuid _uuid;
  final int _maxBatchSize;
  final int _maxNetworkRetries;
  final Duration _initialRetryDelay;
  final Duration _scheduledRetryBaseDelay;
  final Duration _maxScheduledRetryDelay;
  final SyncTraceRunner _traceRunner;
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
    final capability = await _evaluateCapabilities();
    final operationsToSync = capability.loansSupported
        ? pending
        : pending
              .where((op) => op.entityType != SyncEntityType.loan.name)
              .toList(growable: false);
    final deferredLoanOperationCount = pending.length - operationsToSync.length;

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

    final changes = _buildChangesPayload(operationsToSync);
    final requestPayload = SyncRequestPayload(
      deviceId: deviceId,
      schemaVersion: capability.schemaVersion,
      clientRequestId: _uuid.v4(),
      lastSyncAt: forceFullSync ? null : state?.lastSuccessfulSyncAt,
      changes: changes.isEmpty ? null : changes,
    );

    try {
      final response = await _syncWithRetry(
        request: requestPayload,
        pendingOperationCount: operationsToSync.length,
        forceFullSync: forceFullSync,
      );

      final processedOperations = _processedOperationCount(response);
      if (processedOperations < operationsToSync.length) {
        final errorText =
            'Sync response did not process all operations '
            '(processed: $processedOperations, pending: ${operationsToSync.length}).';

        for (final op in operationsToSync) {
          await _syncDao.markOperationFailed(op.id, errorText);
        }

        await _syncDao.upsertSyncState(
          consecutiveFailures: (state?.consecutiveFailures ?? 0) + 1,
          nextRetryAt: _scheduledRetryAt((state?.consecutiveFailures ?? 0) + 1),
        );

        return SyncAttemptResult(
          executed: true,
          success: false,
          message:
              'Sync partially processed. Local queue kept for retry. '
              'Processed $processedOperations of ${operationsToSync.length} change(s).',
          error: errorText,
          stackTrace: null,
          pendingOperations: pending.length,
          processedOperations: processedOperations,
          syncedCollections: response.syncedCollections,
          syncedItems: response.syncedItems,
          syncedTags: response.syncedTags,
          syncedLoans: response.syncedLoans,
          conflictCount: response.conflicts.length,
          partial: true,
        );
      }

      final applyResult = await _serverChangesApplier.apply(
        response.serverChanges,
      );

      for (final op in operationsToSync) {
        await _syncDao.markOperationSynced(op.id);
      }

      await _syncDao.upsertSyncState(
        lastSuccessfulSyncAt: response.lastSyncAt.toUtc(),
        consecutiveFailures: 0,
        clearNextRetryAt: true,
      );

      return SyncAttemptResult(
        executed: true,
        success: true,
        message:
            'Sync completed: ${response.syncedCollections} collections, '
            '${response.syncedItems} items, ${response.syncedTags} tags, '
            '${response.syncedLoans} loans. '
            'Applied ${applyResult.appliedTotal} remote change(s).'
            '${deferredLoanOperationCount > 0 ? ' Deferred $deferredLoanOperationCount loan change(s) until backend loan sync support is enabled.' : ''}',
        pendingOperations: pending.length,
        processedOperations: processedOperations,
        syncedCollections: response.syncedCollections,
        syncedItems: response.syncedItems,
        syncedTags: response.syncedTags,
        syncedLoans: response.syncedLoans,
        conflictCount: response.conflicts.length,
        partial: false,
        appliedServerCollections: applyResult.appliedCollections,
        appliedServerItems: applyResult.appliedItems,
        appliedServerTags: applyResult.appliedTags,
        appliedServerLoans: applyResult.appliedLoans,
        skippedServerCollections: applyResult.skippedCollections,
        skippedServerItems: applyResult.skippedItems,
        skippedServerTags: applyResult.skippedTags,
        skippedServerLoans: applyResult.skippedLoans,
      );
    } on SyncAuthRequiredException catch (error) {
      await _syncDao.upsertSyncState(clearNextRetryAt: true);
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
      for (final op in operationsToSync) {
        await _syncDao.markOperationFailed(op.id, errorText);
      }

      final nextFailureCount = (state?.consecutiveFailures ?? 0) + 1;
      final shouldScheduleRetry = _isRetryableNetworkError(error);
      await _syncDao.upsertSyncState(
        consecutiveFailures: nextFailureCount,
        nextRetryAt: shouldScheduleRetry
            ? _scheduledRetryAt(nextFailureCount)
            : null,
        clearNextRetryAt: !shouldScheduleRetry,
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
      for (final op in operationsToSync) {
        await _syncDao.markOperationFailed(op.id, errorText);
      }

      await _syncDao.upsertSyncState(
        consecutiveFailures: (state?.consecutiveFailures ?? 0) + 1,
        clearNextRetryAt: true,
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
    final loans = <Map<String, dynamic>>[];

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
      } else if (op.entityType == SyncEntityType.loan.name) {
        loans.add(payload);
      }
    }

    return SyncChangesPayload(
      collections: collections,
      items: items,
      tags: tags,
      loans: loans,
    );
  }

  int _processedOperationCount(SyncResponsePayload response) {
    return response.syncedCollections +
        response.syncedItems +
        response.syncedTags +
        response.syncedLoans +
        response.conflicts.length;
  }

  Future<_SyncCapabilityEvaluation> _evaluateCapabilities() async {
    var schemaVersion = 'v1';
    var loansSupported = false;

    try {
      final capabilities = await _backendClient.getCapabilities();
      final acceptedVersions = capabilities.acceptedSchemaVersions
          .map((version) => version.trim().toLowerCase())
          .toSet();
      if (acceptedVersions.contains('v2') ||
          acceptedVersions.contains('v2-loans')) {
        schemaVersion = 'v2';
      }

      final supportedEntities = capabilities.supportedEntities
          .map((entity) => entity.trim().toLowerCase())
          .toSet();
      if (supportedEntities.contains('loan') ||
          supportedEntities.contains('loans')) {
        loansSupported = true;
      } else if (schemaVersion == 'v2') {
        loansSupported = true;
      }
    } catch (_) {
      // Treat capabilities as unknown and stay with safest defaults.
    }

    return _SyncCapabilityEvaluation(
      schemaVersion: schemaVersion,
      loansSupported: loansSupported,
    );
  }

  Future<SyncResponsePayload> _syncWithRetry({
    required SyncRequestPayload request,
    required int pendingOperationCount,
    required bool forceFullSync,
  }) async {
    DioException? lastDioError;

    for (var attempt = 0; attempt <= _maxNetworkRetries; attempt++) {
      try {
        return await _traceRunner(
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

  DateTime _scheduledRetryAt(int consecutiveFailures) {
    final safeFailures = consecutiveFailures < 1 ? 1 : consecutiveFailures;
    final multiplier = 1 << (safeFailures - 1);
    final baseMillis = _scheduledRetryBaseDelay.inMilliseconds * multiplier;
    final cappedMillis = min(
      baseMillis,
      _maxScheduledRetryDelay.inMilliseconds,
    );
    final jitterMillis = _random.nextInt(1500);
    return DateTime.now().toUtc().add(
      Duration(milliseconds: cappedMillis + jitterMillis),
    );
  }

  static Future<T> _defaultTraceRunner<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return FirebasePerformanceService.instance.traceAsync(
      traceName,
      operation,
      attributes: attributes,
    );
  }
}

class _SyncCapabilityEvaluation {
  const _SyncCapabilityEvaluation({
    required this.schemaVersion,
    required this.loansSupported,
  });

  final String schemaVersion;
  final bool loansSupported;
}
