import 'package:collection_tracker/core/extensions/date_extensions.dart';
import 'package:collection_tracker/features/collections/presentation/view_models/collection_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionDetailsSheet extends ConsumerWidget {
  const CollectionDetailsSheet({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionStreamProvider(collectionId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: collectionAsync.when(
            data: (collection) {
              if (collection == null) {
                return const Center(child: Text('Collection not found'));
              }
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          collection.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(label: Text(collection.type.name)),
                            const SizedBox(width: 8),
                            Text(
                              '${collection.itemCount} items',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildStatRow(
                          context,
                          'Created',
                          collection.createdAt.formatMediumDate(),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          context,
                          'Last Updated',
                          collection.updatedAt.formatMediumDate(),
                        ),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.pop(); // Close sheet
                            context.push('/collections/$collectionId/edit');
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Collection'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
