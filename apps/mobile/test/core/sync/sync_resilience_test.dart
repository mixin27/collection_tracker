import 'dart:collection';
import 'dart:convert';

import 'package:collection_tracker/core/sync/sync_orchestrator.dart';
import 'package:collection_tracker/core/sync/sync_server_changes_applier.dart';
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_api/sync_api.dart';

void main() {
  group('SyncOrchestrator retry scheduling', () {
    late AppDatabase database;
    late SyncServerChangesApplier applier;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      applier = SyncServerChangesApplier(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('schedules nextRetryAt after retryable network failure', () async {
      final failingClient = _SequenceBackendClient(
        outcomes: <Object>[
          DioException(
            requestOptions: RequestOptions(path: '/sync'),
            type: DioExceptionType.connectionError,
            error: Exception('offline'),
          ),
        ],
      );
      final orchestrator = SyncOrchestrator(
        syncDao: database.syncDao,
        backendClient: failingClient,
        serverChangesApplier: applier,
        maxNetworkRetries: 0,
        traceRunner: _runWithoutTrace,
      );

      await orchestrator.enqueueOperation(
        entityType: SyncEntityType.collection,
        entityId: 'collection-1',
        operationType: SyncOperationType.upsert,
        payload: _collectionPayload(id: 'collection-1'),
      );

      final before = DateTime.now().toUtc();
      final result = await orchestrator.syncNow(deviceId: 'device-1');
      final state = await database.syncDao.getSyncState();

      expect(result.success, isFalse);
      expect(state, isNotNull);
      expect(state!.consecutiveFailures, 1);
      expect(state.nextRetryAt, isNotNull);
      expect(state.nextRetryAt!.toUtc().isAfter(before), isTrue);
    });

    test('clears retry schedule after successful retry', () async {
      final sequenceClient = _SequenceBackendClient(
        outcomes: <Object>[
          DioException(
            requestOptions: RequestOptions(path: '/sync'),
            type: DioExceptionType.connectionError,
            error: Exception('offline'),
          ),
          SyncResponsePayload(
            lastSyncAt: DateTime.now().toUtc(),
            serverChanges: const SyncChangesPayload(),
            conflicts: const <Map<String, dynamic>>[],
            syncedCollections: 1,
            syncedItems: 0,
            syncedTags: 0,
            syncedLoans: 0,
            conflictsResolved: 0,
          ),
        ],
      );
      final orchestrator = SyncOrchestrator(
        syncDao: database.syncDao,
        backendClient: sequenceClient,
        serverChangesApplier: applier,
        maxNetworkRetries: 0,
        traceRunner: _runWithoutTrace,
      );

      await orchestrator.enqueueOperation(
        entityType: SyncEntityType.collection,
        entityId: 'collection-1',
        operationType: SyncOperationType.upsert,
        payload: _collectionPayload(id: 'collection-1'),
      );

      final first = await orchestrator.syncNow(deviceId: 'device-1');
      final firstState = await database.syncDao.getSyncState();
      expect(first.success, isFalse);
      expect(firstState?.nextRetryAt, isNotNull);

      final second = await orchestrator.syncNow(deviceId: 'device-1');
      final secondState = await database.syncDao.getSyncState();
      final pending = await database.syncDao.getPendingOperations(limit: 10);

      expect(second.success, isTrue);
      expect(secondState?.consecutiveFailures, 0);
      expect(secondState?.nextRetryAt, isNull);
      expect(pending, isEmpty);
    });
  });

  group('SyncServerChangesApplier merge safety', () {
    late AppDatabase database;
    late SyncServerChangesApplier applier;
    late DateTime now;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      applier = SyncServerChangesApplier(database: database);
      now = DateTime.now().toUtc();

      await database.collectionDao.insertCollection(
        CollectionsCompanion.insert(
          id: 'collection-1',
          name: 'Collection',
          type: 'Custom',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('skips server item update when local outbox has pending op', () async {
      final localUpdatedAt = now.add(const Duration(minutes: 10));
      await database.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: 'collection-1',
          title: 'Local title',
          createdAt: now,
          updatedAt: localUpdatedAt,
        ),
      );

      await database.syncDao.enqueueOperation(
        id: 'item:item-1:upsert',
        entityType: 'item',
        entityId: 'item-1',
        operationType: 'upsert',
        payload: jsonEncode(<String, dynamic>{
          'id': 'item-1',
          'updatedAt': localUpdatedAt.toIso8601String(),
          'isDeleted': false,
        }),
      );

      final result = await applier.apply(
        SyncChangesPayload(
          items: <Map<String, dynamic>>[
            _itemPayload(
              id: 'item-1',
              title: 'Server title',
              updatedAt: now.add(const Duration(minutes: 20)),
            ),
          ],
        ),
      );

      final item = await database.itemDao.getItemById('item-1');
      expect(result.appliedItems, 0);
      expect(result.skippedItems, 1);
      expect(item?.title, 'Local title');
    });

    test(
      'skips outdated server item update when local timestamp is newer',
      () async {
        final localUpdatedAt = now.add(const Duration(minutes: 10));
        await database.itemDao.insertItem(
          ItemsCompanion.insert(
            id: 'item-1',
            collectionId: 'collection-1',
            title: 'Local latest',
            createdAt: now,
            updatedAt: localUpdatedAt,
          ),
        );

        final result = await applier.apply(
          SyncChangesPayload(
            items: <Map<String, dynamic>>[
              _itemPayload(
                id: 'item-1',
                title: 'Server stale',
                updatedAt: now.add(const Duration(minutes: 5)),
              ),
            ],
          ),
        );

        final item = await database.itemDao.getItemById('item-1');
        expect(result.appliedItems, 0);
        expect(result.skippedItems, 1);
        expect(item?.title, 'Local latest');
      },
    );
  });
}

class _SequenceBackendClient implements SyncBackendClient {
  _SequenceBackendClient({required List<Object> outcomes})
    : _outcomes = Queue<Object>.from(outcomes);

  final Queue<Object> _outcomes;

  @override
  Future<SyncCapabilities> getCapabilities() async {
    return const SyncCapabilities(
      apiVersion: 'v1',
      supportedModes: <String>['full', 'incremental'],
      maxBatchSize: 1000,
      conflictStrategy: 'last_write_wins',
      acceptedSchemaVersions: <String>['v1'],
      supportedEntities: <String>['collection', 'item', 'tag'],
    );
  }

  @override
  Future<SyncResponsePayload> sync(SyncRequestPayload request) async {
    if (_outcomes.isEmpty) {
      throw StateError('No outcome queued for sync call');
    }

    final next = _outcomes.removeFirst();
    if (next is DioException) {
      throw next;
    }
    if (next is SyncResponsePayload) {
      return next;
    }
    throw StateError('Unsupported queued outcome type: ${next.runtimeType}');
  }
}

Map<String, dynamic> _collectionPayload({required String id}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return <String, dynamic>{
    'id': id,
    'name': 'Collection',
    'type': 'Custom',
    'description': 'Desc',
    'itemCount': 0,
    'version': 1,
    'isDeleted': false,
    'createdAt': now,
    'updatedAt': now,
  };
}

Map<String, dynamic> _itemPayload({
  required String id,
  required String title,
  required DateTime updatedAt,
}) {
  return <String, dynamic>{
    'id': id,
    'collectionId': 'collection-1',
    'title': title,
    'barcode': null,
    'coverImageUrl': null,
    'coverImagePath': null,
    'description': null,
    'notes': null,
    'metadata': null,
    'condition': null,
    'purchasePrice': null,
    'purchaseDate': null,
    'currentValue': null,
    'location': null,
    'isFavorite': false,
    'isWishlist': false,
    'sortOrder': 0,
    'quantity': 1,
    'version': 1,
    'isDeleted': false,
    'createdAt': updatedAt
        .subtract(const Duration(minutes: 1))
        .toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'tagIds': const <String>[],
  };
}

Future<T> _runWithoutTrace<T>(
  String traceName,
  Future<T> Function() operation, {
  Map<String, String>? attributes,
}) {
  return operation();
}
