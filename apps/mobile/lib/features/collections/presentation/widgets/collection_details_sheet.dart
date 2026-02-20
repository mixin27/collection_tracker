import 'package:collection_tracker/core/extensions/date_extensions.dart';
import 'package:collection_tracker/features/collections/presentation/view_models/collection_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class CollectionDetailsSheet extends ConsumerWidget {
  const CollectionDetailsSheet({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionStreamProvider(collectionId));
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: collectionAsync.when(
        data: (collection) {
          if (collection == null) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Collection not found',
              message: 'The selected collection is not available.',
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                AppButton(
                  label: 'Edit Collection',
                  variant: AppButtonVariant.secondary,
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.pop();
                    context.push('/collections/$collectionId/edit');
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          );
        },
        loading: () => const LoadingView(message: 'Loading collection...'),
        error: (error, _) => ErrorView(message: 'Error: $error'),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
