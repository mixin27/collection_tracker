import 'package:database/src/app_database.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';

part 'collection_dao.g.dart';

@DriftAccessor(tables: [Collections])
class CollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  // Get all collections
  Future<List<CollectionData>> getAllCollections() {
    return (select(
      collections,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();
  }

  // Watch all collections
  Stream<List<CollectionData>> watchAllCollections() {
    return (select(
      collections,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).watch();
  }

  // Get collection by ID
  Future<CollectionData?> getCollectionById(String id) {
    return (select(
      collections,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Watch collection by ID
  Stream<CollectionData?> watchCollectionById(String id) {
    return (select(
      collections,
    )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  // Insert collection
  Future<int> insertCollection(CollectionsCompanion collection) {
    return into(collections).insert(collection);
  }

  // Update collection
  Future<int> updateCollection(CollectionsCompanion collection) {
    return (update(
      collections,
    )..where((tbl) => tbl.id.equals(collection.id.value))).write(collection);
  }

  // Delete collection
  Future<int> deleteCollection(String id) {
    return (delete(collections)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Update item count
  Future<void> updateItemCount(String id, int count) async {
    await (update(collections)..where((tbl) => tbl.id.equals(id))).write(
      CollectionsCompanion(
        itemCount: Value(count),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Increment item count
  Future<void> incrementItemCount(String id) async {
    final collection = await getCollectionById(id);
    if (collection != null) {
      await updateItemCount(id, collection.itemCount + 1);
    }
  }

  // Decrement item count
  Future<void> decrementItemCount(String id) async {
    final collection = await getCollectionById(id);
    if (collection != null && collection.itemCount > 0) {
      await updateItemCount(id, collection.itemCount - 1);
    }
  }
}
