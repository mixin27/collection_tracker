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
      final List<ItemData> data;

      if (limit != null && offset != null) {
        data = await _dao.getItemsPaginated(
          collectionId: collectionId,
          limit: limit,
          offset: offset,
        );
      } else {
        data = await _dao.getItemsByCollection(collectionId);
      }

      final items = data.map(_mapToEntity).toList();
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
      final data = await _dao.getItemById(id);
      if (data == null) {
        return const Left(
          AppException.notFound(
            message: 'Item not found',
            resourceType: 'Item',
          ),
        );
      }
      return Right(_mapToEntity(data));
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
      await _dao.insertItem(companion);
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
      final success = await _dao.updateItem(companion);
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
        .watchItemsByCollection(collectionId)
        .map((data) => data.map(_mapToEntity).toList());
  }

  @override
  Stream<Item?> watchItemById(String id) {
    return _dao
        .watchItemById(id)
        .map((data) => data != null ? _mapToEntity(data) : null);
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
      final items = data.map(_mapToEntity).toList();
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

  Item _mapToEntity(ItemData data) {
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
      quantity: data.quantity,
      sortOrder: data.sortOrder,
      tags: [], // Tags will be implemented later
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
      quantity: Value(entity.quantity),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
