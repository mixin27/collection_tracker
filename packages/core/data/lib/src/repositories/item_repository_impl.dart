import 'dart:convert';

import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../sync/outbox_sync_writer.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemDao _dao;
  final SyncOutboxWriter? _syncOutboxWriter;

  ItemRepositoryImpl(this._dao, {SyncDao? syncDao})
    : _syncOutboxWriter = syncDao != null ? SyncOutboxWriter(syncDao) : null;

  @override
  Future<Either<AppException, List<Item>>> getItems({
    required String collectionId,
    int? limit,
    int? offset,
  }) async {
    try {
      final List<(ItemData, List<String>)> data;

      if (limit != null && offset != null) {
        data = await _dao.getItemsWithTagsPaginated(
          collectionId: collectionId,
          limit: limit,
          offset: offset,
        );
      } else {
        data = await _dao.getItemsWithTags(collectionId);
      }

      final items = data
          .map((entry) => _mapToEntity(entry.$1, entry.$2))
          .toList();
      return Right(items);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load items',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Item>> getItemById(String id) async {
    try {
      final data = await _dao.getItemWithTags(id);
      if (data == null) {
        return const Left(
          AppException.notFound(
            message: 'Item not found',
            resourceType: 'Item',
          ),
        );
      }
      return Right(_mapToEntity(data.$1, data.$2));
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load item',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Item>> createItem(Item item) async {
    try {
      final companion = _mapToCompanion(item);
      await _dao.insertItem(companion, tags: item.tags);
      await _queueItemUpsert(item);
      return Right(item);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to create item',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Item>> updateItem(Item item) async {
    try {
      final companion = _mapToCompanion(item);
      final success = await _dao.updateItem(companion, tags: item.tags);
      if (success < 1) {
        return const Left(
          AppException.notFound(
            message: 'Item not found',
            resourceType: 'Item',
          ),
        );
      }
      await _queueItemUpsert(item);
      return Right(item);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to update item',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteItem(String id) async {
    try {
      final existing = await _dao.getItemWithTags(id);
      await _dao.deleteItem(id);
      if (existing != null) {
        await _queueItemDelete(_mapToEntity(existing.$1, existing.$2));
      }
      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to delete item',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Stream<List<Item>> watchItems(String collectionId) {
    return _dao
        .watchItemsWithTags(collectionId)
        .map(
          (data) =>
              data.map((entry) => _mapToEntity(entry.$1, entry.$2)).toList(),
        );
  }

  @override
  Stream<Item?> watchItemById(String id) {
    return _dao
        .watchItemWithTags(id)
        .map((data) => data != null ? _mapToEntity(data.$1, data.$2) : null);
  }

  @override
  Stream<List<Item>> watchAllFavoriteItems() {
    return _dao.watchAllFavoriteItems().asyncMap((data) async {
      final mapped = await Future.wait(
        data.map((item) async {
          final tags = await _dao.getTagsForItem(item.id);
          return _mapToEntity(item, tags);
        }),
      );
      return mapped;
    });
  }

  @override
  Stream<List<Item>> watchAllWishlistItems() {
    return _dao.watchAllWishlistItems().asyncMap((data) async {
      final mapped = await Future.wait(
        data.map((item) async {
          final tags = await _dao.getTagsForItem(item.id);
          return _mapToEntity(item, tags);
        }),
      );
      return mapped;
    });
  }

  @override
  Stream<List<Item>> watchItemsByTag(String tagName) {
    return _dao.watchItemsByTag(tagName).asyncMap((data) async {
      final mapped = await Future.wait(
        data.map((item) async {
          final tags = await _dao.getTagsForItem(item.id);
          return _mapToEntity(item, tags);
        }),
      );
      return mapped;
    });
  }

  @override
  Stream<List<(DateTime, double)>> watchPriceHistory(String itemId) {
    return _dao
        .watchPriceHistoryForItem(itemId)
        .map((rows) => rows.map((row) => (row.recordedAt, row.value)).toList());
  }

  @override
  Stream<List<(String, int)>> watchTagsWithUsage() {
    return _dao.watchTagsWithUsage();
  }

  @override
  Future<Either<AppException, List<Item>>> searchItems({
    required String collectionId,
    required String query,
  }) async {
    try {
      final data = await _dao.searchItems(
        collectionId: collectionId,
        query: query,
      );
      final items = await Future.wait(
        data.map((item) async {
          final tags = await _dao.getTagsForItem(item.id);
          return _mapToEntity(item, tags);
        }),
      );
      return Right(items);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to search items',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> reorderItems(List<String> itemIds) async {
    try {
      await _dao.reorderItems(itemIds);
      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to reorder items',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> renameTag({
    required String oldName,
    required String newName,
  }) async {
    try {
      final sourceTagBefore = await _dao.getTagByName(oldName.trim());
      final targetTagBefore = await _dao.getTagByName(newName.trim());

      await _dao.renameTag(oldName: oldName, newName: newName);

      if (sourceTagBefore != null) {
        if (targetTagBefore == null) {
          final renamedTag = await _dao.getTagByName(newName.trim());
          if (renamedTag != null) {
            await _queueTagUpsert(renamedTag);
          }
        } else {
          final mergedTarget = await _dao.getTagByName(newName.trim());
          if (mergedTarget != null) {
            await _queueTagUpsert(mergedTarget);
          }
          await _queueTagDelete(sourceTagBefore);
        }
      }

      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to rename tag',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> mergeTags({
    required String sourceName,
    required String targetName,
  }) async {
    try {
      final sourceTag = await _dao.getTagByName(sourceName.trim());
      final targetTag = await _dao.getTagByName(targetName.trim());

      await _dao.mergeTags(sourceName: sourceName, targetName: targetName);

      if (targetTag != null) {
        final mergedTarget = await _dao.getTagByName(targetName.trim());
        if (mergedTarget != null) {
          await _queueTagUpsert(mergedTarget);
        }
      }
      if (sourceTag != null) {
        await _queueTagDelete(sourceTag);
      }

      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to merge tags',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteTag(String tagName) async {
    try {
      final existingTag = await _dao.getTagByName(tagName.trim());
      await _dao.deleteTagByName(tagName);
      if (existingTag != null) {
        await _queueTagDelete(existingTag);
      }
      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to delete tag',
          stackTrace: stack,
        ),
      );
    }
  }

  Item _mapToEntity(ItemData data, [List<String> tags = const []]) {
    return Item(
      id: data.id,
      collectionId: data.collectionId,
      title: data.title,
      barcode: data.barcode,
      coverImageUrl: data.coverImageUrl,
      coverImagePath: data.coverImagePath,
      description: data.description,
      notes: data.notes,
      metadata: data.metadata != null
          ? jsonDecode(data.metadata!) as Map<String, dynamic>
          : null,
      condition: data.condition != null
          ? ItemCondition.values.firstWhere(
              (e) => e.name == data.condition,
              orElse: () => ItemCondition.good,
            )
          : null,
      purchasePrice: data.purchasePrice,
      purchaseDate: data.purchaseDate,
      currentValue: data.currentValue,
      location: data.location,
      isFavorite: data.isFavorite,
      isWishlist: data.isWishlist,
      quantity: data.quantity,
      sortOrder: data.sortOrder,
      tags: tags,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  ItemsCompanion _mapToCompanion(Item entity) {
    return ItemsCompanion(
      id: Value(entity.id),
      collectionId: Value(entity.collectionId),
      title: Value(entity.title),
      barcode: Value(entity.barcode),
      coverImageUrl: Value(entity.coverImageUrl),
      coverImagePath: Value(entity.coverImagePath),
      description: Value(entity.description),
      notes: Value(entity.notes),
      metadata: Value(
        entity.metadata != null ? jsonEncode(entity.metadata) : null,
      ),
      condition: Value(entity.condition?.name),
      purchasePrice: Value(entity.purchasePrice),
      purchaseDate: Value(entity.purchaseDate),
      currentValue: Value(entity.currentValue),
      location: Value(entity.location),
      isFavorite: Value(entity.isFavorite),
      isWishlist: Value(entity.isWishlist),
      quantity: Value(entity.quantity),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  Future<void> _queueItemUpsert(Item item) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    try {
      final tagRecords = await _dao.getTagsByNames(item.tags);
      for (final tag in tagRecords) {
        await _queueTagUpsert(tag);
      }

      final payload = _itemSyncPayload(
        item: item,
        tagIds: tagRecords.map((tag) => tag.id).toList(),
      );
      await writer.queueUpsert(
        entityType: 'item',
        entityId: item.id,
        payload: payload,
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Future<void> _queueItemDelete(Item item) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    try {
      final deletedAt = DateTime.now();
      final payload = _itemSyncPayload(
        item: item,
        tagIds: const <String>[],
        isDeleted: true,
        deletedAt: deletedAt,
        updatedAt: deletedAt,
      );
      await writer.queueDelete(
        entityType: 'item',
        entityId: item.id,
        payload: payload,
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Future<void> _queueTagUpsert(TagData tag) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    try {
      await writer.queueUpsert(
        entityType: 'tag',
        entityId: tag.id,
        payload: _tagSyncPayload(tag: tag),
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Future<void> _queueTagDelete(TagData tag) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    try {
      final deletedAt = DateTime.now();
      await writer.queueDelete(
        entityType: 'tag',
        entityId: tag.id,
        payload: _tagSyncPayload(
          tag: tag,
          isDeleted: true,
          deletedAt: deletedAt,
          updatedAt: deletedAt,
        ),
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Map<String, dynamic> _itemSyncPayload({
    required Item item,
    required List<String> tagIds,
    bool isDeleted = false,
    DateTime? deletedAt,
    DateTime? updatedAt,
  }) {
    final effectiveUpdatedAt = updatedAt ?? item.updatedAt;
    return {
      'id': item.id,
      'collectionId': item.collectionId,
      'title': item.title,
      'barcode': item.barcode,
      'coverImageUrl': item.coverImageUrl,
      'coverImagePath': item.coverImagePath,
      'description': item.description,
      'notes': item.notes,
      'metadata': item.metadata != null ? jsonEncode(item.metadata) : null,
      'condition': item.condition?.name,
      'purchasePrice': item.purchasePrice,
      'purchaseDate': item.purchaseDate?.toUtc().toIso8601String(),
      'currentValue': item.currentValue,
      'location': item.location,
      'isFavorite': item.isFavorite,
      'isWishlist': item.isWishlist,
      'sortOrder': item.sortOrder,
      'quantity': item.quantity,
      'version': 1,
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt.toUtc().toIso8601String(),
      'createdAt': item.createdAt.toUtc().toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toUtc().toIso8601String(),
      'tagIds': tagIds,
    };
  }

  Map<String, dynamic> _tagSyncPayload({
    required TagData tag,
    bool isDeleted = false,
    DateTime? deletedAt,
    DateTime? updatedAt,
  }) {
    final effectiveUpdatedAt = updatedAt ?? tag.updatedAt;
    return {
      'id': tag.id,
      'name': tag.name,
      'color': tag.color,
      'version': 1,
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt.toUtc().toIso8601String(),
      'createdAt': tag.createdAt.toUtc().toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toUtc().toIso8601String(),
    };
  }
}
