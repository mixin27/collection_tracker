import 'package:collection_tracker/features/collections/presentation/view_models/collections_view_model.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../view_models/items_view_model.dart';
import '../view_models/tag_items_view_model.dart';
import '../widgets/item_card.dart';

class TagItemsScreen extends ConsumerStatefulWidget {
  final String tagName;

  const TagItemsScreen({required this.tagName, super.key});

  @override
  ConsumerState<TagItemsScreen> createState() => _TagItemsScreenState();
}

enum _TagItemsSort { newest, oldest, title }

class _TagItemsScreenState extends ConsumerState<TagItemsScreen> {
  final Set<String> _collapsedCollections = <String>{};
  _TagItemsSort _sort = _TagItemsSort.newest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tagName = widget.tagName;
    final itemsAsync = ref.watch(tagItemsProvider(tagName));
    final collectionsAsync = ref.watch(collectionsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tagItemsTitle(tagName)),
        actions: [
          PopupMenuButton<_TagItemsSort>(
            tooltip: l10n.tagItemsSortTooltip,
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _TagItemsSort.newest,
                child: Text(l10n.tagItemsSortNewest),
              ),
              PopupMenuItem(
                value: _TagItemsSort.oldest,
                child: Text(l10n.tagItemsSortOldest),
              ),
              PopupMenuItem(
                value: _TagItemsSort.title,
                child: Text(l10n.tagItemsSortTitle),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => collectionsAsync.when(
          data: (collections) =>
              _buildContent(context, ref, items, collections),
          loading: () => LoadingView(message: l10n.tagItemsLoadingCollections),
          error: (error, _) => ErrorView(message: l10n.tagItemsError('$error')),
        ),
        loading: () => LoadingView(message: l10n.tagItemsLoadingItems),
        error: (error, _) => ErrorView(message: l10n.tagItemsError('$error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    List<Collection> collections,
  ) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: l10n.tagItemsEmptyTitle,
        message: l10n.tagItemsEmptyMessage,
      );
    }

    final collectionNames = {
      for (final collection in collections) collection.id: collection.name,
    };
    final grouped = <String, List<Item>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.collectionId, () => []).add(item);
    }
    final sortedCollectionIds = grouped.keys.toList()
      ..sort((a, b) {
        final nameA = collectionNames[a] ?? a;
        final nameB = collectionNames[b] ?? b;
        return nameA.compareTo(nameB);
      });

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: sortedCollectionIds.length,
      itemBuilder: (context, sectionIndex) {
        final collectionId = sortedCollectionIds[sectionIndex];
        final sectionItems = _sortedItems(grouped[collectionId]!);
        final collectionName =
            collectionNames[collectionId] ?? l10n.tagItemsUnknownCollection;
        final isCollapsed = _collapsedCollections.contains(collectionId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
              borderRadius: BorderRadius.circular(AppRadii.md),
              onTap: () => _toggleCollectionCollapse(collectionId),
              child: Row(
                children: [
                  Icon(isCollapsed ? Icons.expand_more : Icons.expand_less),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      collectionName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '(${sectionItems.length})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  IconButton(
                    tooltip: l10n.tagItemsOpenCollectionTooltip,
                    icon: const Icon(Icons.open_in_new, size: 20),
                    onPressed: () => context.go('/collections/$collectionId'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppAnimatedSwitcher(
              duration: AppMotion.medium,
              child: isCollapsed
                  ? const SizedBox.shrink()
                  : Column(
                      key: ValueKey(collectionId),
                      children: sectionItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final heroTag = 'tag_${widget.tagName}_${item.id}';
                        return AppReveal(
                          delay: AppMotion.stagger * index,
                          child: ItemCard(
                            item: item,
                            heroTag: heroTag,
                            onTap: () => context.pushNamed(
                              'item-detail',
                              pathParameters: {'id': item.id},
                              queryParameters: {'heroTag': heroTag},
                            ),
                            onDelete: () =>
                                _showDeleteDialog(context, ref, item),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }

  List<Item> _sortedItems(List<Item> items) {
    final sorted = List<Item>.from(items);
    sorted.sort((a, b) {
      return switch (_sort) {
        _TagItemsSort.newest => b.createdAt.compareTo(a.createdAt),
        _TagItemsSort.oldest => a.createdAt.compareTo(b.createdAt),
        _TagItemsSort.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
      };
    });
    return sorted;
  }

  void _toggleCollectionCollapse(String collectionId) {
    setState(() {
      if (_collapsedCollections.contains(collectionId)) {
        _collapsedCollections.remove(collectionId);
      } else {
        _collapsedCollections.add(collectionId);
      }
    });
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(context.l10n.itemsDeleteTitle),
      content: Text(context.l10n.itemsDeleteMessage(item.title)),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        AppButton(
          label: context.l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(deleteItemProvider(item.id).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.itemsDeleted(item.title))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.tagItemsDeleteFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
