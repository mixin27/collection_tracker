import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../view_models/items_view_model.dart';
import '../../../../core/providers/providers.dart';
import '../providers/items_filter_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/item_grid_card.dart';
import '../widgets/item_filter_sheet.dart';

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
                    filter.showOnlyFavorites ||
                    filter.sortBy != ItemSortBy.createdAt,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: () => _showFilterSheet(context),
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
      body: AnimatedSwitcher(
        duration: 300.ms,
        child: displayItemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                key: const ValueKey('empty'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSearching ||
                              filter.conditions.isNotEmpty ||
                              filter.showOnlyFavorites
                          ? Icons.search_off
                          : Icons.inventory_2_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      items.isEmpty &&
                              (_isSearching ||
                                  filter.conditions.isNotEmpty ||
                                  filter.showOnlyFavorites)
                          ? 'No matches found'
                          : 'No items yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSearching ||
                              filter.conditions.isNotEmpty ||
                              filter.showOnlyFavorites
                          ? 'Try adjusting your filters'
                          : 'Add your first item to get started',
                    ),
                    if (!_isSearching &&
                        filter.conditions.isEmpty &&
                        !filter.showOnlyFavorites) ...[
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push(
                          '/collections/${widget.collectionId}/add-item',
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ],
                ),
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
                    return Container(
                      key: ValueKey(item.id),
                      child:
                          ItemCard(
                                item: item,
                                onTap: () => context.push('/items/${item.id}'),
                                onDelete: () =>
                                    _showDeleteDialog(context, ref, item),
                              )
                              .animate(delay: (index * 50).ms)
                              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOut,
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
                    return ItemCard(
                          item: item,
                          onTap: () => context.push('/items/${item.id}'),
                          onDelete: () => _showDeleteDialog(context, ref, item),
                        )
                        .animate(delay: (index * 50).ms)
                        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
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
                  return ItemGridCard(
                        item: item,
                        onTap: () => context.push('/items/${item.id}'),
                        onDelete: () => _showDeleteDialog(context, ref, item),
                      )
                      .animate(delay: (index * 50).ms)
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      );
                },
              );
            }
          },
          loading: () => const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            key: const ValueKey('error'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading items: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      filteredItemsListProvider(widget.collectionId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
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
      builder: (context) => const ItemFilterSheet(),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
