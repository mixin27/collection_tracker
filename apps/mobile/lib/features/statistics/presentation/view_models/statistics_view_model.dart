import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_view_model.g.dart';

class CollectionStatistics {
  final int totalCollections;
  final int totalItems;
  final Map<CollectionType, int> itemsByType;
  final Map<ItemCondition, int> itemsByCondition;
  final int favoriteItems;
  final double totalValue;
  final Collection? largestCollection;
  final List<Collection> recentCollections;

  CollectionStatistics({
    required this.totalCollections,
    required this.totalItems,
    required this.itemsByType,
    required this.itemsByCondition,
    required this.favoriteItems,
    required this.totalValue,
    this.largestCollection,
    required this.recentCollections,
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
    double totalValue = 0.0;

    for (final item in allItems) {
      if (item.condition != null) {
        itemsByCondition[item.condition!] =
            (itemsByCondition[item.condition!] ?? 0) + 1;
      }
      if (item.isFavorite) {
        favoriteCount++;
      }
      if (item.purchasePrice != null) {
        totalValue += item.purchasePrice! * item.quantity;
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

    return CollectionStatistics(
      totalCollections: collections.length,
      totalItems: allItems.length,
      itemsByType: itemsByType,
      itemsByCondition: itemsByCondition,
      favoriteItems: favoriteCount,
      totalValue: totalValue,
      largestCollection: largestCollection,
      recentCollections: recent,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
