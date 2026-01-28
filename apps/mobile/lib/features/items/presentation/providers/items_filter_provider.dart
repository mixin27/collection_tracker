import 'package:collection_tracker/features/items/presentation/view_models/items_view_model.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'items_filter_provider.g.dart';

enum ItemSortBy {
  custom('Custom'),
  title('Title'),
  createdAt('Date Created'),
  purchaseDate('Date Purchased'),
  currentValue('Value'),
  quantity('Quantity');

  final String label;
  const ItemSortBy(this.label);
}

class ItemFilterState {
  final String searchQuery;
  final ItemSortBy sortBy;
  final bool sortAscending;
  final Set<ItemCondition> conditions;
  final bool showOnlyFavorites;

  const ItemFilterState({
    this.searchQuery = '',
    this.sortBy = ItemSortBy.custom,
    this.sortAscending = true,
    this.conditions = const {},
    this.showOnlyFavorites = false,
  });

  ItemFilterState copyWith({
    String? searchQuery,
    ItemSortBy? sortBy,
    bool? sortAscending,
    Set<ItemCondition>? conditions,
    bool? showOnlyFavorites,
  }) {
    return ItemFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      conditions: conditions ?? this.conditions,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}

@riverpod
class ItemFilter extends _$ItemFilter {
  @override
  ItemFilterState build() {
    return const ItemFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(ItemSortBy sortBy) {
    if (state.sortBy == sortBy) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortBy: sortBy, sortAscending: false);
    }
  }

  void toggleCondition(ItemCondition condition) {
    final nextConditions = Set<ItemCondition>.from(state.conditions);
    if (nextConditions.contains(condition)) {
      nextConditions.remove(condition);
    } else {
      nextConditions.add(condition);
    }
    state = state.copyWith(conditions: nextConditions);
  }

  void toggleFavorites() {
    state = state.copyWith(showOnlyFavorites: !state.showOnlyFavorites);
  }

  void reset() {
    state = const ItemFilterState();
  }
}

@riverpod
Stream<List<Item>> filteredItemsList(Ref ref, String collectionId) async* {
  final itemsAsync = ref.watch(itemsListProvider(collectionId));
  final filter = ref.watch(itemFilterProvider);

  if (itemsAsync.hasValue) {
    var filtered = List<Item>.from(itemsAsync.value!);

    // Search Query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Favorites
    if (filter.showOnlyFavorites) {
      filtered = filtered.where((item) => item.isFavorite).toList();
    }

    // Conditions
    if (filter.conditions.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.condition != null &&
            filter.conditions.contains(item.condition);
      }).toList();
    }

    // Sorting
    filtered.sort((a, b) {
      final comparison = switch (filter.sortBy) {
        ItemSortBy.custom => a.sortOrder.compareTo(b.sortOrder),
        ItemSortBy.title => a.title.compareTo(b.title),
        ItemSortBy.createdAt => a.createdAt.compareTo(b.createdAt),
        ItemSortBy.purchaseDate => (a.purchaseDate ?? DateTime(1900)).compareTo(
          b.purchaseDate ?? DateTime(1900),
        ),
        ItemSortBy.currentValue => (a.currentValue ?? 0).compareTo(
          b.currentValue ?? 0,
        ),
        ItemSortBy.quantity => a.quantity.compareTo(b.quantity),
      };
      return filter.sortAscending ? comparison : -comparison;
    });

    yield filtered;
  }
}
