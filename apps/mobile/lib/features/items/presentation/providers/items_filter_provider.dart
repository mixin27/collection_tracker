import 'dart:async';

import 'package:collection_tracker/features/items/presentation/view_models/items_view_model.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

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
  final Set<String> tags;
  final bool showOnlyFavorites;
  final bool showOnlyWishlist;

  const ItemFilterState({
    this.searchQuery = '',
    this.sortBy = ItemSortBy.custom,
    this.sortAscending = true,
    this.conditions = const {},
    this.tags = const {},
    this.showOnlyFavorites = false,
    this.showOnlyWishlist = false,
  });

  ItemFilterState copyWith({
    String? searchQuery,
    ItemSortBy? sortBy,
    bool? sortAscending,
    Set<ItemCondition>? conditions,
    Set<String>? tags,
    bool? showOnlyFavorites,
    bool? showOnlyWishlist,
  }) {
    return ItemFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      conditions: conditions ?? this.conditions,
      tags: tags ?? this.tags,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      showOnlyWishlist: showOnlyWishlist ?? this.showOnlyWishlist,
    );
  }
}

@riverpod
class ItemFilter extends _$ItemFilter {
  static const _sortByKey = 'items_filter_sort_by';
  static const _sortAscendingKey = 'items_filter_sort_ascending';
  static const _favoritesOnlyKey = 'items_filter_only_favorites';
  static const _wishlistOnlyKey = 'items_filter_only_wishlist';

  late final PrefsStorageService _prefs;

  @override
  ItemFilterState build() {
    _prefs = PrefsStorageService.instance;

    final sortByIndex =
        _prefs.readSync<int>(_sortByKey) ?? ItemSortBy.custom.index;
    final sortBy = sortByIndex < 0 || sortByIndex >= ItemSortBy.values.length
        ? ItemSortBy.custom
        : ItemSortBy.values[sortByIndex];
    final sortAscending = _prefs.readSync<bool>(_sortAscendingKey) ?? true;
    final showOnlyFavorites = _prefs.readSync<bool>(_favoritesOnlyKey) ?? false;
    final showOnlyWishlist = _prefs.readSync<bool>(_wishlistOnlyKey) ?? false;

    return ItemFilterState(
      sortBy: sortBy,
      sortAscending: sortAscending,
      showOnlyFavorites: showOnlyFavorites,
      showOnlyWishlist: showOnlyWishlist,
    );
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
    _persistDisplayPrefs();
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

  void toggleTag(String tag) {
    final nextTags = Set<String>.from(state.tags);
    if (nextTags.contains(tag)) {
      nextTags.remove(tag);
    } else {
      nextTags.add(tag);
    }
    state = state.copyWith(tags: nextTags);
  }

  void toggleFavorites() {
    state = state.copyWith(showOnlyFavorites: !state.showOnlyFavorites);
    _persistDisplayPrefs();
  }

  void toggleWishlist() {
    state = state.copyWith(showOnlyWishlist: !state.showOnlyWishlist);
    _persistDisplayPrefs();
  }

  void reset() {
    state = const ItemFilterState();
    _persistDisplayPrefs();
  }

  void _persistDisplayPrefs() {
    unawaited(_prefs.save<int>(_sortByKey, state.sortBy.index));
    unawaited(_prefs.save<bool>(_sortAscendingKey, state.sortAscending));
    unawaited(_prefs.save<bool>(_favoritesOnlyKey, state.showOnlyFavorites));
    unawaited(_prefs.save<bool>(_wishlistOnlyKey, state.showOnlyWishlist));
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
            (item.description?.toLowerCase().contains(query) ?? false) ||
            item.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Favorites
    if (filter.showOnlyFavorites) {
      filtered = filtered.where((item) => item.isFavorite).toList();
    }

    // Wishlist
    if (filter.showOnlyWishlist) {
      filtered = filtered.where((item) => item.isWishlist).toList();
    }

    // Conditions
    if (filter.conditions.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.condition != null &&
            filter.conditions.contains(item.condition);
      }).toList();
    }

    // Tags (match any selected tag)
    if (filter.tags.isNotEmpty) {
      filtered = filtered.where((item) {
        final itemTags = item.tags.map((tag) => tag.toLowerCase()).toSet();
        return filter.tags.any(
          (selected) => itemTags.contains(selected.toLowerCase()),
        );
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
