import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../../collections/presentation/view_models/collections_view_model.dart';
import '../../../collections/presentation/widgets/collection_details_sheet.dart';
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
    final collectionAsync = ref.watch(
      collectionDetailProvider(widget.collectionId),
    );
    final viewMode = ref.watch(itemsViewModeProvider);
    final filter = ref.watch(itemFilterProvider);
    final collectionName = collectionAsync.asData?.value?.name ?? 'Items';

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
            ? AppInput(
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
            : Text(collectionName),
        actions: [
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
              return Column(
                key: const ValueKey('list-layout'),
                children: [
                  _ItemsOverviewBar(
                    itemCount: items.length,
                    viewMode: viewMode,
                    sortBy: filter.sortBy,
                    hasActiveFilters:
                        filter.conditions.isNotEmpty ||
                        filter.tags.isNotEmpty ||
                        filter.showOnlyFavorites ||
                        filter.showOnlyWishlist ||
                        filter.searchQuery.trim().isNotEmpty,
                    onToggleViewMode: () =>
                        ref.read(itemsViewModeProvider.notifier).toggle(),
                    onOpenFilter: () => _showFilterSheet(context),
                    onOpenDetails: () => _showCollectionDetails(context),
                  ),
                  Expanded(
                    child: canReorder
                        ? ReorderableListView.builder(
                            key: const ValueKey('list-reorder'),
                            padding: const EdgeInsets.all(AppSpacing.lg),
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
                              final itemIds = reorderedItems
                                  .map((e) => e.id)
                                  .toList();
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
                                  onTap: () => context.push(
                                    '/items/${item.id}?heroTag=$heroTag',
                                  ),
                                  onDelete: () =>
                                      _showDeleteDialog(context, ref, item),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            key: const ValueKey('list'),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final heroTag = 'collection_items_${item.id}';
                              return AppReveal(
                                delay: AppMotion.stagger * index,
                                child: ItemCard(
                                  item: item,
                                  heroTag: heroTag,
                                  onTap: () => context.push(
                                    '/items/${item.id}?heroTag=$heroTag',
                                  ),
                                  onDelete: () =>
                                      _showDeleteDialog(context, ref, item),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            } else {
              return Column(
                key: const ValueKey('grid-layout'),
                children: [
                  _ItemsOverviewBar(
                    itemCount: items.length,
                    viewMode: viewMode,
                    sortBy: filter.sortBy,
                    hasActiveFilters:
                        filter.conditions.isNotEmpty ||
                        filter.tags.isNotEmpty ||
                        filter.showOnlyFavorites ||
                        filter.showOnlyWishlist ||
                        filter.searchQuery.trim().isNotEmpty,
                    onToggleViewMode: () =>
                        ref.read(itemsViewModeProvider.notifier).toggle(),
                    onOpenFilter: () => _showFilterSheet(context),
                    onOpenDetails: () => _showCollectionDetails(context),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1080
                            ? 4
                            : constraints.maxWidth > 760
                            ? 3
                            : 2;

                        return GridView.builder(
                          key: const ValueKey('grid'),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
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
                                onTap: () => context.push(
                                  '/items/${item.id}?heroTag=$heroTag',
                                ),
                                onDelete: () =>
                                    _showDeleteDialog(context, ref, item),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
          loading: () => const LoadingView(
            key: ValueKey('loading'),
            message: 'Loading items...',
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
    showAppSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemFilterSheet(collectionId: widget.collectionId),
    );
  }

  void _showCollectionDetails(BuildContext context) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          CollectionDetailsSheet(collectionId: widget.collectionId),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
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

class _ItemsOverviewBar extends StatelessWidget {
  final int itemCount;
  final ItemSortBy sortBy;
  final ItemsViewMode viewMode;
  final bool hasActiveFilters;
  final VoidCallback onToggleViewMode;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenDetails;

  const _ItemsOverviewBar({
    required this.itemCount,
    required this.sortBy,
    required this.viewMode,
    required this.hasActiveFilters,
    required this.onToggleViewMode,
    required this.onOpenFilter,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '$itemCount items',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Sorted by ${sortBy.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Collection details',
              onPressed: onOpenDetails,
              icon: const Icon(Icons.info_outline_rounded),
            ),
            IconButton(
              tooltip: viewMode == ItemsViewMode.list
                  ? 'Switch to grid'
                  : 'Switch to list',
              onPressed: onToggleViewMode,
              icon: Icon(
                viewMode == ItemsViewMode.list
                    ? Icons.grid_view_rounded
                    : Icons.view_agenda_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Open filters',
              onPressed: onOpenFilter,
              icon: Badge(
                isLabelVisible: hasActiveFilters,
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
