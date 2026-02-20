import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../view_models/items_view_model.dart';
import '../../../../core/providers/providers.dart';
import '../providers/items_filter_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/item_grid_card.dart';
import '../widgets/item_filter_sheet.dart';
import '../../../collections/presentation/widgets/collection_details_sheet.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const ItemsScreen({required this.collectionId, super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Item>? _optimisticItems; // For smooth reordering without flashing

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(
      filteredItemsListProvider(widget.collectionId),
    );
    final viewMode = ref.watch(itemsViewModeProvider);
    final filter = ref.watch(itemFilterProvider);

    // Use optimistic items if available, otherwise use stream data
    // Clear optimistic items when stream data matches the expected order
    final displayItemsAsync = itemsAsync.when(
      data: (streamItems) {
        if (_optimisticItems != null) {
          // Check if stream data matches our optimistic order
          final idsMatch =
              streamItems.length == _optimisticItems!.length &&
              streamItems.asMap().entries.every((entry) {
                final index = entry.key;
                final streamItem = entry.value;
                return streamItem.id == _optimisticItems![index].id;
              });

          if (idsMatch) {
            // Stream data matches, clear optimistic state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _optimisticItems = null;
                });
              }
            });
          }
          // Keep showing optimistic items until stream matches
          return AsyncValue.data(_optimisticItems!);
        }
        return AsyncValue.data(streamItems);
      },
      loading: () => itemsAsync,
      error: (e, s) => itemsAsync,
    );

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(itemFilterProvider.notifier).setSearchQuery(value);
                },
              )
            : const Text('Items'),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showCollectionDetails(context),
            ),
            IconButton(
              icon: Icon(
                viewMode == ItemsViewMode.list
                    ? Icons.grid_view
                    : Icons.view_list,
              ),
              onPressed: () {
                ref.read(itemsViewModeProvider.notifier).toggle();
              },
            ),
            IconButton(
              icon: Badge(
                isLabelVisible:
                    filter.conditions.isNotEmpty ||
                    filter.tags.isNotEmpty ||
                    filter.showOnlyFavorites ||
                    filter.sortBy != ItemSortBy.createdAt,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: () => _showFilterSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.sell_outlined),
              tooltip: 'Manage tags',
              onPressed: () => context.push('/settings/tags'),
            ),
          ],
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  ref.read(itemFilterProvider.notifier).setSearchQuery('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: AppAnimatedSwitcher(
        duration: AppMotion.medium,
        child: displayItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                key: const ValueKey('empty'),
                icon:
                    _isSearching ||
                        filter.conditions.isNotEmpty ||
                        filter.tags.isNotEmpty ||
                        filter.showOnlyFavorites
                    ? Icons.search_off
                    : Icons.inventory_2_outlined,
                title:
                    items.isEmpty &&
                        (_isSearching ||
                            filter.conditions.isNotEmpty ||
                            filter.tags.isNotEmpty ||
                            filter.showOnlyFavorites)
                    ? 'No matches found'
                    : 'No items yet',
                message:
                    _isSearching ||
                        filter.conditions.isNotEmpty ||
                        filter.tags.isNotEmpty ||
                        filter.showOnlyFavorites
                    ? 'Try adjusting your filters'
                    : 'Add your first item to get started',
                action:
                    !_isSearching &&
                        filter.conditions.isEmpty &&
                        filter.tags.isEmpty &&
                        !filter.showOnlyFavorites
                    ? AppButton(
                        label: 'Add Item',
                        icon: const Icon(Icons.add),
                        onPressed: () => context.push(
                          '/collections/${widget.collectionId}/add-item',
                        ),
                      )
                    : null,
              );
            }

            if (viewMode == ItemsViewMode.list) {
              final canReorder = filter.sortBy == ItemSortBy.custom;

              if (canReorder) {
                return ReorderableListView.builder(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final reorderedItems = List<Item>.from(items);
                    final item = reorderedItems.removeAt(oldIndex);
                    reorderedItems.insert(newIndex, item);

                    // Optimistically update UI immediately
                    setState(() {
                      _optimisticItems = reorderedItems;
                    });

                    // Persist to database in background
                    final itemIds = reorderedItems.map((e) => e.id).toList();
                    ref.read(reorderItemsProvider(itemIds).future);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final heroTag = 'collection_items_${item.id}';
                    return AppReveal(
                      key: ValueKey(item.id),
                      delay: AppMotion.stagger * index,
                      child: ItemCard(
                        item: item,
                        heroTag: heroTag,
                        onTap: () =>
                            context.push('/items/${item.id}?heroTag=$heroTag'),
                        onDelete: () => _showDeleteDialog(context, ref, item),
                      ),
                    );
                  },
                );
              } else {
                return ListView.builder(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final heroTag = 'collection_items_${item.id}';
                    return AppReveal(
                      delay: AppMotion.stagger * index,
                      child: ItemCard(
                        item: item,
                        heroTag: heroTag,
                        onTap: () =>
                            context.push('/items/${item.id}?heroTag=$heroTag'),
                        onDelete: () => _showDeleteDialog(context, ref, item),
                      ),
                    );
                  },
                );
              }
            } else {
              return GridView.builder(
                key: const ValueKey('grid'),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final heroTag = 'collection_items_${item.id}';
                  return AppReveal(
                    delay: AppMotion.stagger * index,
                    beginOffsetY: 0.02,
                    beginScale: 0.94,
                    child: ItemGridCard(
                      item: item,
                      heroTag: heroTag,
                      onTap: () =>
                          context.push('/items/${item.id}?heroTag=$heroTag'),
                      onDelete: () => _showDeleteDialog(context, ref, item),
                    ),
                  );
                },
              );
            }
          },
          loading: () => const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => ErrorView(
            key: const ValueKey('error'),
            message: 'Error loading items: $error',
            onRetry: () {
              ref.invalidate(filteredItemsListProvider(widget.collectionId));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/collections/${widget.collectionId}/add-item'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemFilterSheet(collectionId: widget.collectionId),
    );
  }

  void _showCollectionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CollectionDetailsSheet(collectionId: widget.collectionId),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(deleteItemProvider(item.id).future);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${item.title} deleted')));
      }
    }
  }
}
