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
  });
}
