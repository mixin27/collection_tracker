import 'package:database/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('CollectionDao', () {
    test('insert and get collection', () async {
      final now = DateTime.now();
      final collection = CollectionsCompanion.insert(
        id: 'coll-1',
        name: 'My Collection',
        type: 'Books',
        createdAt: now,
        updatedAt: now,
      );

      await db.collectionDao.insertCollection(collection);

      final result = await db.collectionDao.getCollectionById('coll-1');
      expect(result, isNotNull);
      expect(result?.name, 'My Collection');
      expect(result?.type, 'Books');
    });

    test('update collection', () async {
      final now = DateTime.now();
      await db.collectionDao.insertCollection(
        CollectionsCompanion.insert(
          id: 'coll-1',
          name: 'Old Name',
          type: 'Books',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.collectionDao.updateCollection(
        CollectionsCompanion(
          id: const Value('coll-1'),
          name: const Value('New Name'),
        ),
      );

      final result = await db.collectionDao.getCollectionById('coll-1');
      expect(result?.name, 'New Name');
    });

    test('delete collection', () async {
      final now = DateTime.now();
      await db.collectionDao.insertCollection(
        CollectionsCompanion.insert(
          id: 'coll-1',
          name: 'To Delete',
          type: 'Books',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.collectionDao.deleteCollection('coll-1');

      final result = await db.collectionDao.getCollectionById('coll-1');
      expect(result, isNull);
    });

    test('item count increment/decrement', () async {
      final now = DateTime.now();
      await db.collectionDao.insertCollection(
        CollectionsCompanion.insert(
          id: 'coll-1',
          name: 'Count Test',
          type: 'Books',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.collectionDao.incrementItemCount('coll-1');
      var result = await db.collectionDao.getCollectionById('coll-1');
      expect(result?.itemCount, 1);

      await db.collectionDao.decrementItemCount('coll-1');
      result = await db.collectionDao.getCollectionById('coll-1');
      expect(result?.itemCount, 0);
    });
  });

  group('ItemDao', () {
    late String collectionId;

    setUp(() async {
      collectionId = 'coll-1';
      final now = DateTime.now();
      await db.collectionDao.insertCollection(
        CollectionsCompanion.insert(
          id: collectionId,
          name: 'Test Collection',
          type: 'Items',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    test('insert and get items', () async {
      final now = DateTime.now();
      final item = ItemsCompanion.insert(
        id: 'item-1',
        collectionId: collectionId,
        title: 'Test Item',
        createdAt: now,
        updatedAt: now,
      );

      await db.itemDao.insertItem(item);

      final items = await db.itemDao.getItemsByCollection(collectionId);
      expect(items.length, 1);
      expect(items.first.title, 'Test Item');
    });

    test('search items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: collectionId,
          title: 'Apple',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-2',
          collectionId: collectionId,
          title: 'Banana',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final results = await db.itemDao.searchItems(
        collectionId: collectionId,
        query: 'App',
      );
      expect(results.length, 1);
      expect(results.first.title, 'Apple');
    });

    test('toggle favorite', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: collectionId,
          title: 'Fav Item',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.itemDao.toggleFavorite('item-1', true);
      var item = await db.itemDao.getItemById('item-1');
      expect(item?.isFavorite, true);

      await db.itemDao.toggleFavorite('item-1', false);
      item = await db.itemDao.getItemById('item-1');
      expect(item?.isFavorite, false);
    });

    test('get total item count', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: collectionId,
          title: 'Item 1',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-2',
          collectionId: collectionId,
          title: 'Item 2',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final count = await db.itemDao.getItemCount(collectionId);
      expect(count, 2);
    });

    test('get items paginated', () async {
      final now = DateTime.now();
      for (var i = 1; i <= 5; i++) {
        await db.itemDao.insertItem(
          ItemsCompanion.insert(
            id: 'item-$i',
            collectionId: collectionId,
            title: 'Item $i',
            createdAt: now.add(Duration(minutes: i)),
            updatedAt: now,
          ),
        );
      }

      // Latest first (item-5, item-4, item-3, item-2, item-1)
      final page1 = await db.itemDao.getItemsPaginated(
        collectionId: collectionId,
        limit: 2,
        offset: 0,
      );
      expect(page1.length, 2);
      expect(page1[0].id, 'item-5');
      expect(page1[1].id, 'item-4');

      final page2 = await db.itemDao.getItemsPaginated(
        collectionId: collectionId,
        limit: 2,
        offset: 2,
      );
      expect(page2.length, 2);
      expect(page2[0].id, 'item-3');
      expect(page2[1].id, 'item-2');
    });

    test('get favorite items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: collectionId,
          title: 'Normal',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-2',
          collectionId: collectionId,
          title: 'Fav',
          createdAt: now,
          updatedAt: now,
          isFavorite: const Value(true),
        ),
      );

      final favors = await db.itemDao.getFavoriteItems(collectionId);
      expect(favors.length, 1);
      expect(favors.first.title, 'Fav');
    });

    test('cascade delete items when collection is deleted', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          collectionId: collectionId,
          title: 'Child Item',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Drift cascade is handled if foreign keys are ON and configured in table
      await db.collectionDao.deleteCollection(collectionId);

      final items = await db.itemDao.getItemsByCollection(collectionId);
      expect(items, isEmpty);
    });

    test('toggle wishlist', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-wish',
          collectionId: collectionId,
          title: 'Wish Item',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.itemDao.toggleWishlist('item-wish', true);
      var item = await db.itemDao.getItemById('item-wish');
      expect(item?.isWishlist, true);

      await db.itemDao.toggleWishlist('item-wish', false);
      item = await db.itemDao.getItemById('item-wish');
      expect(item?.isWishlist, false);
    });

    test('get wishlist items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-normal-2',
          collectionId: collectionId,
          title: 'Normal',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-wish-2',
          collectionId: collectionId,
          title: 'Wish',
          createdAt: now,
          updatedAt: now,
          isWishlist: const Value(true),
        ),
      );

      final wishes = await db.itemDao.getWishlistItems(collectionId);
      expect(wishes.length, 1);
      expect(wishes.first.title, 'Wish');
    });

    test('insert item with tags', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tags-1',
          collectionId: collectionId,
          title: 'Tagged Item',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['Manga', 'Rare'],
      );

      final itemWithTags = await db.itemDao.getItemWithTags('item-tags-1');
      expect(itemWithTags, isNotNull);
      expect(itemWithTags!.$2, containsAll(<String>['Manga', 'Rare']));
    });

    test('update item tags replaces existing tags', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tags-2',
          collectionId: collectionId,
          title: 'Replace Tags',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['OldTag'],
      );

      await db.itemDao.updateItem(
        ItemsCompanion(
          id: const Value('item-tags-2'),
          title: const Value('Replace Tags'),
          updatedAt: Value(now.add(const Duration(minutes: 1))),
        ),
        tags: const ['NewTagA', 'NewTagB'],
      );

      final tags = await db.itemDao.getTagsForItem('item-tags-2');
      expect(tags, containsAll(<String>['NewTagA', 'NewTagB']));
      expect(tags, isNot(contains('OldTag')));
    });

    test('deleting item removes item-tag relations', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tags-3',
          collectionId: collectionId,
          title: 'Delete Tagged',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['ToDelete'],
      );

      await db.itemDao.deleteItem('item-tags-3');
      final tags = await db.itemDao.getTagsForItem('item-tags-3');

      expect(tags, isEmpty);
    });

    test('watch tags with usage returns counts', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-usage-1',
          collectionId: collectionId,
          title: 'Usage 1',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['Shared', 'UniqueA'],
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-usage-2',
          collectionId: collectionId,
          title: 'Usage 2',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['Shared'],
      );

      final tagsWithUsage = await db.itemDao.getTagsWithUsage();
      expect(tagsWithUsage, contains(('Shared', 2)));
      expect(tagsWithUsage, contains(('UniqueA', 1)));
    });

    test('rename tag updates tag name for linked items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-rename-1',
          collectionId: collectionId,
          title: 'Rename Tag Item',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['OldName'],
      );

      await db.itemDao.renameTag(oldName: 'OldName', newName: 'NewName');
      final tags = await db.itemDao.getTagsForItem('item-rename-1');

      expect(tags, contains('NewName'));
      expect(tags, isNot(contains('OldName')));
    });

    test('merge tags consolidates duplicates across items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-merge-1',
          collectionId: collectionId,
          title: 'Merge 1',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['SourceTag', 'TargetTag'],
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-merge-2',
          collectionId: collectionId,
          title: 'Merge 2',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['SourceTag'],
      );

      await db.itemDao.mergeTags(
        sourceName: 'SourceTag',
        targetName: 'TargetTag',
      );

      final tagsItem1 = await db.itemDao.getTagsForItem('item-merge-1');
      final tagsItem2 = await db.itemDao.getTagsForItem('item-merge-2');
      final allTags = await db.itemDao.getTagsWithUsage();

      expect(tagsItem1.where((t) => t == 'TargetTag').length, 1);
      expect(tagsItem1, isNot(contains('SourceTag')));
      expect(tagsItem2, contains('TargetTag'));
      expect(tagsItem2, isNot(contains('SourceTag')));
      expect(allTags.any((entry) => entry.$1 == 'SourceTag'), isFalse);
    });

    test('delete tag removes it from all items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-delete-tag-1',
          collectionId: collectionId,
          title: 'Delete Tag 1',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['DeleteMe', 'KeepMe'],
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-delete-tag-2',
          collectionId: collectionId,
          title: 'Delete Tag 2',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['DeleteMe'],
      );

      await db.itemDao.deleteTagByName('DeleteMe');

      final tags1 = await db.itemDao.getTagsForItem('item-delete-tag-1');
      final tags2 = await db.itemDao.getTagsForItem('item-delete-tag-2');
      final allTags = await db.itemDao.getTagsWithUsage();

      expect(tags1, contains('KeepMe'));
      expect(tags1, isNot(contains('DeleteMe')));
      expect(tags2, isNot(contains('DeleteMe')));
      expect(allTags.any((entry) => entry.$1 == 'DeleteMe'), isFalse);
    });

    test('get items by tag returns matching collection items', () async {
      final now = DateTime.now();
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tag-query-1',
          collectionId: collectionId,
          title: 'Match A',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['FilterTag'],
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tag-query-2',
          collectionId: collectionId,
          title: 'No Match',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['OtherTag'],
      );
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-tag-query-3',
          collectionId: collectionId,
          title: 'Match B',
          createdAt: now,
          updatedAt: now,
        ),
        tags: const ['FilterTag'],
      );

      final filtered = await db.itemDao.getItemsByTag('FilterTag');

      expect(filtered.length, 2);
      expect(
        filtered.map((item) => item.title),
        containsAll(['Match A', 'Match B']),
      );
      expect(filtered.map((item) => item.title), isNot(contains('No Match')));
    });
  });
}
