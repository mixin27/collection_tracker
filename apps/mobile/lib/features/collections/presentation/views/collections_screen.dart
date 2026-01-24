import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/collections_view_model.dart';
import '../widgets/collection_card.dart';
import '../widgets/empty_collections_view.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: collectionsAsync.when(
        data: (collections) {
          if (collections.isEmpty) {
            return const EmptyCollectionsView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(collectionsViewModelProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return CollectionCard(
                  collection: collection,
                  onTap: () => context.push('/collections/${collection.id}'),
                  onDelete: () => _showDeleteDialog(context, ref, collection),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading collections',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(collectionsViewModelProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/collections/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? '
          'This will also delete all ${collection.itemCount} items in this collection.',
        ),
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
      await ref
          .read(collectionsViewModelProvider.notifier)
          .deleteCollection(collection.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${collection.name} deleted'),
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          ),
        );
      }
    }
  }
}
