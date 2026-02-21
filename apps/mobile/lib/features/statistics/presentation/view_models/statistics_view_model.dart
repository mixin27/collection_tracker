import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_view_model.g.dart';

class CollectionStatistics {
  final int totalCollections;
  final int totalItems;
  final int totalQuantity;
  final Map<CollectionType, int> itemsByType;
  final Map<ItemCondition, int> itemsByCondition;
  final int favoriteItems;
  final int wishlistItems;
  final double totalValue;
  final int pricedItems;
  final double averageItemValue;
  final Collection? largestCollection;
  final List<Collection> recentCollections;
  final List<(Collection, double)> topValuedCollections;

  CollectionStatistics({
    required this.totalCollections,
    required this.totalItems,
    required this.totalQuantity,
    required this.itemsByType,
    required this.itemsByCondition,
    required this.favoriteItems,
    required this.wishlistItems,
    required this.totalValue,
    required this.pricedItems,
    required this.averageItemValue,
    this.largestCollection,
    required this.recentCollections,
    required this.topValuedCollections,
  });
}

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  @override
  Future<CollectionStatistics> build() async {
    final collectionRepo = ref.watch(collectionRepositoryProvider);
    final itemRepo = ref.watch(itemRepositoryProvider);

    // Get all collections
    final collectionsResult = await collectionRepo.getCollections();
    final collections = collectionsResult.fold(
      (exception) => <Collection>[],
      (data) => data,
    );

    // Get all items from all collections
    final List<Item> allItems = [];
    for (final collection in collections) {
      final itemsResult = await itemRepo.getItems(collectionId: collection.id);
      itemsResult.fold((exception) => null, (items) => allItems.addAll(items));
    }

    // Calculate statistics
    final itemsByType = <CollectionType, int>{};
    for (final collection in collections) {
      itemsByType[collection.type] =
          (itemsByType[collection.type] ?? 0) + collection.itemCount;
    }

    final itemsByCondition = <ItemCondition, int>{};
    int favoriteCount = 0;
    int wishlistCount = 0;
    int pricedItems = 0;
    int totalQuantity = 0;
    double totalValue = 0.0;
    final valueByCollection = <String, double>{};

    for (final item in allItems) {
      totalQuantity += item.quantity;
      if (item.condition != null) {
        itemsByCondition[item.condition!] =
            (itemsByCondition[item.condition!] ?? 0) + 1;
      }
      if (item.isFavorite) {
        favoriteCount++;
      }
      if (item.isWishlist) {
        wishlistCount++;
      }
      final effectiveValue = item.currentValue ?? item.purchasePrice;
      if (effectiveValue != null) {
        pricedItems++;
        final itemTotalValue = effectiveValue * item.quantity;
        totalValue += itemTotalValue;
        valueByCollection[item.collectionId] =
            (valueByCollection[item.collectionId] ?? 0) + itemTotalValue;
      }
    }

    // Find largest collection
    Collection? largestCollection;
    if (collections.isNotEmpty) {
      largestCollection = collections.reduce(
        (a, b) => a.itemCount > b.itemCount ? a : b,
      );
    }

    // Get recent collections (last 5)
    final recentCollections = [...collections]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = recentCollections.take(5).toList();
    final collectionsById = {
      for (final collection in collections) collection.id: collection,
    };
    final topValuedCollections =
        valueByCollection.entries
            .where((entry) => collectionsById.containsKey(entry.key))
            .map((entry) => (collectionsById[entry.key]!, entry.value))
            .toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));

    return CollectionStatistics(
      totalCollections: collections.length,
      totalItems: allItems.length,
      totalQuantity: totalQuantity,
      itemsByType: itemsByType,
      itemsByCondition: itemsByCondition,
      favoriteItems: favoriteCount,
      wishlistItems: wishlistCount,
      totalValue: totalValue,
      pricedItems: pricedItems,
      averageItemValue: pricedItems == 0 ? 0 : totalValue / pricedItems,
      largestCollection: largestCollection,
      recentCollections: recent,
      topValuedCollections: topValuedCollections.take(5).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
