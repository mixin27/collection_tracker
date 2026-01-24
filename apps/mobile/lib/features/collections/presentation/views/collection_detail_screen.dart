import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/collections_view_model.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailScreen({required this.collectionId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionDetailProvider(collectionId));

    return collectionAsync.when(
      data: (collection) {
        if (collection == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Collection not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(collection.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // todo(mixin27): Navigate to edit collection
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (collection.description != null &&
                  collection.description!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(collection.description!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _StatRow(
                        label: 'Total Items',
                        value: '${collection.itemCount}',
                      ),
                      _StatRow(
                        label: 'Type',
                        value: collection.type.name.toUpperCase(),
                      ),
                      _StatRow(
                        label: 'Created',
                        value: _formatDate(collection.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.push('/collections/$collectionId/items'),
                icon: const Icon(Icons.list),
                label: const Text('View Items'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/collections/$collectionId/add-item'),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
