import 'dart:convert';

import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemDao _dao;

  ItemRepositoryImpl(this._dao);

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
      await _dao.deleteItem(id);
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
}
