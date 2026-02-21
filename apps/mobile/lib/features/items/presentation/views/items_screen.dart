import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../../../l10n/l10n.dart';
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
    final l10n = context.l10n;
    final itemsAsync = ref.watch(
      filteredItemsListProvider(widget.collectionId),
    );
    final collectionAsync = ref.watch(
      collectionDetailProvider(widget.collectionId),
    );
    final viewMode = ref.watch(itemsViewModeProvider);
    final filter = ref.watch(itemFilterProvider);
    final collectionName =
        collectionAsync.asData?.value?.name ?? l10n.itemsTitle;

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
                decoration: InputDecoration(
                  hintText: l10n.itemsSearchHint,
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
                    ? l10n.itemsNoMatchesTitle
                    : l10n.itemsNoItemsTitle,
                message:
                    _isSearching ||
                        filter.conditions.isNotEmpty ||
                        filter.tags.isNotEmpty ||
                        filter.showOnlyFavorites
                    ? l10n.itemsNoMatchesMessage
                    : l10n.itemsNoItemsMessage,
                action:
                    !_isSearching &&
                        filter.conditions.isEmpty &&
                        filter.tags.isEmpty &&
                        !filter.showOnlyFavorites
                    ? AppButton(
                        label: l10n.itemsAddButton,
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
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
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
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
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
          loading: () => LoadingView(
            key: const ValueKey('loading'),
            message: l10n.itemsLoadingMessage,
          ),
          error: (error, stack) => ErrorView(
            key: const ValueKey('error'),
            message: l10n.itemsErrorLoading('$error'),
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
    final l10n = context.l10n;
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(l10n.itemsDeleteTitle),
      content: Text(l10n.itemsDeleteMessage(item.title)),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed == true && context.mounted) {
      await ref.read(deleteItemProvider(item.id).future);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.itemsDeleted(item.title))));
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;
            return Row(
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
                    context.l10n.itemsOverviewCount(itemCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.itemsSortedBy(_sortLabel(context, sortBy)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                IconButton(
                  tooltip: context.l10n.itemsCollectionDetailsTooltip,
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.info_outline_rounded),
                ),
                IconButton(
                  tooltip: viewMode == ItemsViewMode.list
                      ? context.l10n.actionSwitchToGrid
                      : context.l10n.actionSwitchToList,
                  onPressed: onToggleViewMode,
                  icon: Icon(
                    viewMode == ItemsViewMode.list
                        ? Icons.grid_view_rounded
                        : Icons.view_agenda_rounded,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.itemsFiltersTooltip,
                  onPressed: onOpenFilter,
                  icon: Badge(
                    isLabelVisible: hasActiveFilters,
                    child: const Icon(Icons.tune_rounded),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _sortLabel(BuildContext context, ItemSortBy sortBy) {
    final l10n = context.l10n;
    return switch (sortBy) {
      ItemSortBy.custom => l10n.itemSortCustom,
      ItemSortBy.title => l10n.itemSortTitle,
      ItemSortBy.createdAt => l10n.itemSortCreatedAt,
      ItemSortBy.purchaseDate => l10n.itemSortPurchaseDate,
      ItemSortBy.currentValue => l10n.itemSortCurrentValue,
      ItemSortBy.quantity => l10n.itemSortQuantity,
    };
  }
}
