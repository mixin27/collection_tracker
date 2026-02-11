import 'package:collection_tracker/features/collections/presentation/view_models/collections_view_model.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/items_view_model.dart';
import '../view_models/tag_items_view_model.dart';
import '../widgets/item_card.dart';

class TagItemsScreen extends ConsumerWidget {
  final String tagName;

  const TagItemsScreen({required this.tagName, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(tagItemsProvider(tagName));
    final collectionsAsync = ref.watch(collectionsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Tag: $tagName')),
      body: itemsAsync.when(
        data: (items) => collectionsAsync.when(
          data: (collections) =>
              _buildContent(context, ref, items, collections),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    List<Collection> collections,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No items found for this tag',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: sortedCollectionIds.length,
      itemBuilder: (context, sectionIndex) {
        final collectionId = sortedCollectionIds[sectionIndex];
        final sectionItems = grouped[collectionId]!;
        final collectionName = collectionNames[collectionId] ?? 'Unknown';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                children: [
                  Text(
                    collectionName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${sectionItems.length})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ...sectionItems.map((item) {
              final heroTag = 'tag_${tagName}_${item.id}';
              return ItemCard(
                item: item,
                heroTag: heroTag,
                onTap: () => context.pushNamed(
                  'item-detail',
                  pathParameters: {'id': item.id},
                  queryParameters: {'heroTag': heroTag},
                ),
                onDelete: () => _showDeleteDialog(context, ref, item),
              );
            }),
          ],
        );
      },
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
        content: Text('Delete "${item.title}"?'),
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

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(deleteItemProvider(item.id).future);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
