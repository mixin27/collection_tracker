import 'package:database/src/app_database.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox, SyncState])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  static const String _primaryStateId = 'primary';

  Future<SyncStateData?> getSyncState() {
    return (select(
      syncState,
    )..where((tbl) => tbl.id.equals(_primaryStateId))).getSingleOrNull();
  }

  Stream<SyncStateData?> watchSyncState() {
    return (select(
      syncState,
    )..where((tbl) => tbl.id.equals(_primaryStateId))).watchSingleOrNull();
  }

  Future<void> upsertSyncState({
    DateTime? lastSuccessfulSyncAt,
    DateTime? lastAttemptedSyncAt,
    String? lastRemoteCursor,
    int? consecutiveFailures,
  }) async {
    final current = await getSyncState();
    final now = DateTime.now();

    await into(syncState).insert(
      SyncStateCompanion(
        id: const Value(_primaryStateId),
        lastSuccessfulSyncAt: Value(
          lastSuccessfulSyncAt ?? current?.lastSuccessfulSyncAt,
        ),
        lastAttemptedSyncAt: Value(
          lastAttemptedSyncAt ?? current?.lastAttemptedSyncAt,
        ),
        lastRemoteCursor: Value(lastRemoteCursor ?? current?.lastRemoteCursor),
        consecutiveFailures: Value(
          consecutiveFailures ?? current?.consecutiveFailures ?? 0,
        ),
        updatedAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> enqueueOperation({
    required String id,
    required String entityType,
    required String entityId,
    required String operationType,
    required String payload,
  }) async {
    final now = DateTime.now();
    await into(syncOutbox).insert(
      SyncOutboxCompanion(
        id: Value(id),
        entityType: Value(entityType),
        entityId: Value(entityId),
        operationType: Value(operationType),
        payload: Value(payload),
        attempts: const Value(0),
        lastAttemptAt: const Value.absent(),
        lastError: const Value.absent(),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<SyncOutboxData>> getPendingOperations({int limit = 100}) {
    return (select(syncOutbox)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
          ..limit(limit))
        .get();
  }

  Stream<int> watchPendingOperationCount() {
    final countExpression = syncOutbox.id.count();
    final query = selectOnly(syncOutbox)..addColumns([countExpression]);
    return query.watchSingle().map((row) => row.read(countExpression) ?? 0);
  }

  Future<void> markOperationSynced(String id) {
    return (delete(syncOutbox)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> markOperationFailed(String id, String error) async {
    final existing = await (select(
      syncOutbox,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (existing == null) {
      return;
    }

    await (update(syncOutbox)..where((tbl) => tbl.id.equals(id))).write(
      SyncOutboxCompanion(
        attempts: Value(existing.attempts + 1),
        lastAttemptAt: Value(DateTime.now()),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearOutbox() async {
    await delete(syncOutbox).go();
  }
}
