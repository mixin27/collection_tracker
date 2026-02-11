import 'package:database/src/app_database.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';

part 'item_dao.g.dart';

@DriftAccessor(tables: [Items, Collections, ItemTags, Tags])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  // Get all tags with usage count
  Future<List<(String, int)>> getTagsWithUsage() async {
    final rows = await customSelect(
      '''
      SELECT t.name AS name, COUNT(it.item_id) AS usage
      FROM tags t
      LEFT JOIN item_tags it ON it.tag_id = t.id
      GROUP BY t.id, t.name
      ORDER BY t.name COLLATE NOCASE ASC
      ''',
      readsFrom: {tags, itemTags},
    ).get();

    return rows
        .map((row) => (row.read<String>('name'), row.read<int>('usage')))
        .toList();
  }

  // Watch all tags with usage count
  Stream<List<(String, int)>> watchTagsWithUsage() {
    return customSelect(
      '''
      SELECT t.name AS name, COUNT(it.item_id) AS usage
      FROM tags t
      LEFT JOIN item_tags it ON it.tag_id = t.id
      GROUP BY t.id, t.name
      ORDER BY t.name COLLATE NOCASE ASC
      ''',
      readsFrom: {tags, itemTags},
    ).watch().map(
      (rows) => rows
          .map((row) => (row.read<String>('name'), row.read<int>('usage')))
          .toList(),
    );
  }

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

  // Get wishlist items
  Future<List<ItemData>> getWishlistItems(String collectionId) {
    return (select(items)
          ..where(
            (tbl) =>
                tbl.collectionId.equals(collectionId) &
                tbl.isWishlist.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  // Watch all favorite items across collections
  Stream<List<ItemData>> watchAllFavoriteItems() {
    return (select(items)
          ..where((tbl) => tbl.isFavorite.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Watch all wishlist items across collections
  Stream<List<ItemData>> watchAllWishlistItems() {
    return (select(items)
          ..where((tbl) => tbl.isWishlist.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Get tags for an item
  Future<List<String>> getTagsForItem(String itemId) async {
    final query = select(itemTags).join([
      innerJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(itemTags.itemId.equals(itemId));

    final result = await query.map((row) => row.readTable(tags).name).get();
    return result;
  }

  // Watch tags for an item
  Stream<List<String>> watchTagsForItem(String itemId) {
    final query = select(itemTags).join([
      innerJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(itemTags.itemId.equals(itemId));

    return query.map((row) => row.readTable(tags).name).watch();
  }

  // Watch items with tags
  Stream<List<(ItemData, List<String>)>> watchItemsWithTags(
    String collectionId,
  ) {
    final query =
        select(items).join([
            leftOuterJoin(itemTags, itemTags.itemId.equalsExp(items.id)),
            leftOuterJoin(tags, tags.id.equalsExp(itemTags.tagId)),
          ])
          ..where(items.collectionId.equals(collectionId))
          ..orderBy([OrderingTerm.desc(items.createdAt)]);

    return query.watch().map((rows) {
      final grouped = <String, (ItemData, List<String>)>{};

      for (final row in rows) {
        final item = row.readTable(items);
        final tag = row.readTableOrNull(tags);

        if (!grouped.containsKey(item.id)) {
          grouped[item.id] = (item, <String>[]);
        }

        if (tag != null) {
          grouped[item.id]!.$2.add(tag.name);
        }
      }

      return grouped.values.toList();
    });
  }

  // Watch item with tags
  Stream<(ItemData, List<String>)?> watchItemWithTags(String id) {
    final query = select(items).join([
      leftOuterJoin(itemTags, itemTags.itemId.equalsExp(items.id)),
      leftOuterJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(items.id.equals(id));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;

      final item = rows.first.readTable(items);
      final tagNames = <String>[];

      for (final row in rows) {
        final tag = row.readTableOrNull(tags);
        if (tag != null) {
          tagNames.add(tag.name);
        }
      }

      return (item, tagNames);
    });
  }

  // Get item with tags
  Future<(ItemData, List<String>)?> getItemWithTags(String id) async {
    final query = select(items).join([
      leftOuterJoin(itemTags, itemTags.itemId.equalsExp(items.id)),
      leftOuterJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(items.id.equals(id));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final item = rows.first.readTable(items);
    final tagNames = <String>[];

    for (final row in rows) {
      final tag = row.readTableOrNull(tags);
      if (tag != null) {
        tagNames.add(tag.name);
      }
    }

    return (item, tagNames);
  }

  // Get items with tags
  Future<List<(ItemData, List<String>)>> getItemsWithTags(
    String collectionId,
  ) async {
    final query =
        select(items).join([
            leftOuterJoin(itemTags, itemTags.itemId.equalsExp(items.id)),
            leftOuterJoin(tags, tags.id.equalsExp(itemTags.tagId)),
          ])
          ..where(items.collectionId.equals(collectionId))
          ..orderBy([OrderingTerm.desc(items.createdAt)]);

    final rows = await query.get();
    final grouped = <String, (ItemData, List<String>)>{};

    for (final row in rows) {
      final item = row.readTable(items);
      final tag = row.readTableOrNull(tags);

      if (!grouped.containsKey(item.id)) {
        grouped[item.id] = (item, <String>[]);
      }

      if (tag != null) {
        grouped[item.id]!.$2.add(tag.name);
      }
    }

    return grouped.values.toList();
  }

  // Get items with tags paginated
  Future<List<(ItemData, List<String>)>> getItemsWithTagsPaginated({
    required String collectionId,
    required int limit,
    required int offset,
  }) async {
    // We need to query items first to apply pagination, then join tags
    final itemsQuery = select(items)
      ..where((tbl) => tbl.collectionId.equals(collectionId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit, offset: offset);

    final itemRows = await itemsQuery.get();

    if (itemRows.isEmpty) {
      return [];
    }

    final itemIds = itemRows.map((e) => e.id).toList();

    final tagsQuery = select(itemTags).join([
      innerJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(itemTags.itemId.isIn(itemIds));

    final tagRows = await tagsQuery.get();

    final tagMap = <String, List<String>>{};
    for (final row in tagRows) {
      final itemId = row.readTable(itemTags).itemId;
      final tagName = row.readTable(tags).name;

      if (!tagMap.containsKey(itemId)) {
        tagMap[itemId] = [];
      }
      tagMap[itemId]!.add(tagName);
    }

    return itemRows.map((item) {
      return (item, tagMap[item.id] ?? <String>[]);
    }).toList();
  }

  // Insert item with tags
  Future<int> insertItem(ItemsCompanion item, {List<String>? tags}) {
    return transaction(() async {
      final id = await into(items).insert(item);
      final collectionId = item.collectionId.value;

      if (tags != null && tags.isNotEmpty) {
        await _updateItemTags(item.id.value, tags);
      }

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

  // Update item with tags
  Future<int> updateItem(ItemsCompanion item, {List<String>? tags}) {
    return transaction(() async {
      final rowsAffected = await (update(
        items,
      )..where((tbl) => tbl.id.equals(item.id.value))).write(item);

      if (rowsAffected > 0 && tags != null) {
        await _updateItemTags(item.id.value, tags);
      }

      return rowsAffected;
    });
  }

  Future<void> _updateItemTags(String itemId, List<String> tagNames) async {
    // 1. Get or create tags
    final tagIds = <String>[];
    for (final name in tagNames) {
      final existingTag = await (select(
        tags,
      )..where((tbl) => tbl.name.equals(name))).getSingleOrNull();

      if (existingTag != null) {
        tagIds.add(existingTag.id);
      } else {
        final newTagId = DateTime.now().microsecondsSinceEpoch
            .toString(); // Simple ID generation
        await into(tags).insert(
          TagsCompanion.insert(
            id: newTagId,
            name: name,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        tagIds.add(newTagId);
      }
    }

    // 2. Remove existing item tags
    await (delete(itemTags)..where((tbl) => tbl.itemId.equals(itemId))).go();

    // 3. Insert new item tags
    for (final tagId in tagIds) {
      await into(
        itemTags,
      ).insert(ItemTagsCompanion.insert(itemId: itemId, tagId: tagId));
    }
  }

  // Rename tag. If new tag already exists, this becomes a merge.
  Future<void> renameTag({
    required String oldName,
    required String newName,
  }) async {
    final sourceName = oldName.trim();
    final targetName = newName.trim();
    if (sourceName.isEmpty || targetName.isEmpty || sourceName == targetName) {
      return;
    }

    await transaction(() async {
      final sourceTag = await (select(
        tags,
      )..where((tbl) => tbl.name.equals(sourceName))).getSingleOrNull();
      if (sourceTag == null) return;

      final targetTag = await (select(
        tags,
      )..where((tbl) => tbl.name.equals(targetName))).getSingleOrNull();

      if (targetTag == null) {
        await (update(tags)..where((tbl) => tbl.id.equals(sourceTag.id))).write(
          TagsCompanion(
            name: Value(targetName),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return;
      }

      await _mergeTagIds(sourceTagId: sourceTag.id, targetTagId: targetTag.id);
      await (delete(tags)..where((tbl) => tbl.id.equals(sourceTag.id))).go();
    });
  }

  // Merge source tag into target tag and remove source tag.
  Future<void> mergeTags({
    required String sourceName,
    required String targetName,
  }) async {
    final source = sourceName.trim();
    final target = targetName.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;

    await transaction(() async {
      final sourceTag = await (select(
        tags,
      )..where((tbl) => tbl.name.equals(source))).getSingleOrNull();
      final targetTag = await (select(
        tags,
      )..where((tbl) => tbl.name.equals(target))).getSingleOrNull();

      if (sourceTag == null || targetTag == null) return;

      await _mergeTagIds(sourceTagId: sourceTag.id, targetTagId: targetTag.id);
      await (delete(tags)..where((tbl) => tbl.id.equals(sourceTag.id))).go();
    });
  }

  // Delete tag and all item-tag relationships by cascade.
  Future<void> deleteTagByName(String tagName) async {
    final normalized = tagName.trim();
    if (normalized.isEmpty) return;

    await (delete(tags)..where((tbl) => tbl.name.equals(normalized))).go();
  }

  Future<void> _mergeTagIds({
    required String sourceTagId,
    required String targetTagId,
  }) async {
    if (sourceTagId == targetTagId) return;

    // Remove rows that would conflict with (item_id, tag_id) unique key.
    await customStatement(
      '''
      DELETE FROM item_tags
      WHERE tag_id = ?
      AND item_id IN (
        SELECT item_id FROM item_tags WHERE tag_id = ?
      )
      ''',
      <Object>[sourceTagId, targetTagId],
    );

    await (update(itemTags)..where((tbl) => tbl.tagId.equals(sourceTagId)))
        .write(ItemTagsCompanion(tagId: Value(targetTagId)));
  }

  // Delete item
  Future<int> deleteItem(String id) {
    return transaction(() async {
      final item = await getItemById(id);
      if (item == null) return 0;

      // Tags and ItemTags are deleted by cascade

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

  Future<void> reorderItems(List<String> itemIds) {
    return transaction(() async {
      for (var i = 0; i < itemIds.length; i++) {
        await (update(items)..where((tbl) => tbl.id.equals(itemIds[i]))).write(
          ItemsCompanion(sortOrder: Value(i), updatedAt: Value(DateTime.now())),
        );
      }
    });
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleWishlist(String id, bool isWishlist) async {
    await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        isWishlist: Value(isWishlist),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
