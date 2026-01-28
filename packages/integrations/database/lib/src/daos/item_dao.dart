import 'package:database/src/app_database.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';

part 'item_dao.g.dart';

@DriftAccessor(tables: [Items, Collections])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  // Get all items in a collection
  Future<List<ItemData>> getItemsByCollection(String collectionId) {
    return (select(items)
          ..where((tbl) => tbl.collectionId.equals(collectionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get items with pagination
  Future<List<ItemData>> getItemsPaginated({
    required String collectionId,
    required int limit,
    required int offset,
  }) {
    return (select(items)
          ..where((tbl) => tbl.collectionId.equals(collectionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  // Get total count of items in collection
  Future<int> getItemCount(String collectionId) async {
    final query = selectOnly(items)
      ..addColumns([items.id.count()])
      ..where(items.collectionId.equals(collectionId));

    final result = await query.getSingle();
    return result.read(items.id.count()) ?? 0;
  }

  // Watch items in a collection
  Stream<List<ItemData>> watchItemsByCollection(String collectionId) {
    return (select(items)
          ..where((tbl) => tbl.collectionId.equals(collectionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Get item by ID
  Future<ItemData?> getItemById(String id) {
    return (select(items)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Watch item by ID
  Stream<ItemData?> watchItemById(String id) {
    return (select(
      items,
    )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  // Search items in collection
  Future<List<ItemData>> searchItems({
    required String collectionId,
    required String query,
  }) {
    return (select(items)
          ..where(
            (tbl) =>
                tbl.collectionId.equals(collectionId) &
                tbl.title.like('%$query%'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Get favorite items
  Future<List<ItemData>> getFavoriteItems(String collectionId) {
    return (select(items)
          ..where(
            (tbl) =>
                tbl.collectionId.equals(collectionId) &
                tbl.isFavorite.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Insert item
  Future<int> insertItem(ItemsCompanion item) {
    return transaction(() async {
      final id = await into(items).insert(item);
      final collectionId = item.collectionId.value;

      final collection = await (select(
        collections,
      )..where((tbl) => tbl.id.equals(collectionId))).getSingleOrNull();

      if (collection != null) {
        await (update(
          collections,
        )..where((tbl) => tbl.id.equals(collectionId))).write(
          CollectionsCompanion(
            itemCount: Value(collection.itemCount + 1),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      return id;
    });
  }

  // Update item
  Future<int> updateItem(ItemsCompanion item) {
    return (update(
      items,
    )..where((tbl) => tbl.id.equals(item.id.value))).write(item);
  }

  // Delete item
  Future<int> deleteItem(String id) {
    return transaction(() async {
      final item = await getItemById(id);
      if (item == null) return 0;

      final deletedCount = await (delete(
        items,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deletedCount > 0) {
        final collection = await (select(
          collections,
        )..where((tbl) => tbl.id.equals(item.collectionId))).getSingleOrNull();

        if (collection != null) {
          await (update(
            collections,
          )..where((tbl) => tbl.id.equals(item.collectionId))).write(
            CollectionsCompanion(
              itemCount: Value((collection.itemCount - 1).clamp(0, 99999999)),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      return deletedCount;
    });
  }

  // Toggle favorite
  // Toggle favorite
  Future<void> reorderItems(List<String> itemIds) {
    return transaction(() async {
      for (var i = 0; i < itemIds.length; i++) {
        await (update(items)..where((tbl) => tbl.id.equals(itemIds[i]))).write(
          ItemsCompanion(sortOrder: Value(i), updatedAt: Value(DateTime.now())),
        );
      }
    });
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
