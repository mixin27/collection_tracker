import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../sync/outbox_sync_writer.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionDao _dao;
  final SyncOutboxWriter? _syncOutboxWriter;

  CollectionRepositoryImpl(this._dao, {SyncDao? syncDao})
    : _syncOutboxWriter = syncDao != null ? SyncOutboxWriter(syncDao) : null;

  @override
  Future<Either<AppException, List<Collection>>> getCollections() async {
    try {
      final data = await _dao.getAllCollections();
      final collections = data.map(_mapToEntity).toList();
      return Right(collections);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load collections',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> getCollectionById(String id) async {
    try {
      final data = await _dao.getCollectionById(id);
      if (data == null) {
        return const Left(
          AppException.notFound(
            message: 'Collection not found',
            resourceType: 'Collection',
          ),
        );
      }
      return Right(_mapToEntity(data));
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> createCollection(
    Collection collection,
  ) async {
    try {
      final companion = _mapToCompanion(collection);
      await _dao.insertCollection(companion);
      await _queueCollectionUpsert(collection);
      return Right(collection);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to create collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> updateCollection(
    Collection collection,
  ) async {
    try {
      final companion = _mapToCompanion(collection);
      final success = await _dao.updateCollection(companion);
      if (success < 1) {
        return const Left(
          AppException.notFound(
            message: 'Collection not found',
            resourceType: 'Collection',
          ),
        );
      }
      await _queueCollectionUpsert(collection);
      return Right(collection);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to update collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteCollection(String id) async {
    try {
      final existing = await _dao.getCollectionById(id);
      await _dao.deleteCollection(id);
      if (existing != null) {
        await _queueCollectionDelete(_mapToEntity(existing));
      }
      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to delete collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    return _dao.watchAllCollections().map(
      (data) => data.map(_mapToEntity).toList(),
    );
  }

  @override
  Stream<Collection?> watchCollectionById(String id) {
    return _dao
        .watchCollectionById(id)
        .map((data) => data != null ? _mapToEntity(data) : null);
  }

  Collection _mapToEntity(CollectionData data) {
    return Collection(
      id: data.id,
      name: data.name,
      type: CollectionType.values.firstWhere(
        (e) => e.name == data.type,
        orElse: () => CollectionType.custom,
      ),
      description: data.description,
      coverImagePath: data.coverImagePath,
      itemCount: data.itemCount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  CollectionsCompanion _mapToCompanion(Collection entity) {
    return CollectionsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      description: Value(entity.description),
      coverImagePath: Value(entity.coverImagePath),
      itemCount: Value(entity.itemCount),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  Future<void> _queueCollectionUpsert(Collection collection) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    final payload = _collectionSyncPayload(collection: collection);
    try {
      await writer.queueUpsert(
        entityType: 'collection',
        entityId: collection.id,
        payload: payload,
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Future<void> _queueCollectionDelete(Collection collection) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    final deletedAt = DateTime.now();
    final payload = _collectionSyncPayload(
      collection: collection,
      isDeleted: true,
      deletedAt: deletedAt,
      updatedAt: deletedAt,
    );
    try {
      await writer.queueDelete(
        entityType: 'collection',
        entityId: collection.id,
        payload: payload,
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Map<String, dynamic> _collectionSyncPayload({
    required Collection collection,
    bool isDeleted = false,
    DateTime? deletedAt,
    DateTime? updatedAt,
  }) {
    final effectiveUpdatedAt = updatedAt ?? collection.updatedAt;
    return {
      'id': collection.id,
      'name': collection.name,
      'type': collection.type.name,
      'description': collection.description,
      'coverImagePath': collection.coverImagePath,
      'itemCount': collection.itemCount,
      'version': 1,
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt.toUtc().toIso8601String(),
      'createdAt': collection.createdAt.toUtc().toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toUtc().toIso8601String(),
    };
  }
}
