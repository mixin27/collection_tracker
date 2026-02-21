import 'package:collection_tracker/features/collections/presentation/view_models/collection_detail_view_model.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import 'collection_visuals.dart';

class CollectionDetailsSheet extends ConsumerWidget {
  const CollectionDetailsSheet({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final collectionAsync = ref.watch(collectionStreamProvider(collectionId));
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: collectionAsync.when(
        data: (collection) {
          if (collection == null) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.collectionDetailsNotFoundTitle,
              message: l10n.collectionDetailsNotFoundMessage,
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
                    Chip(
                      label: Text(
                        collectionTypeLabel(context, collection.type),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.itemsCountWithValue(collection.itemCount),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatRow(
                  context,
                  l10n.collectionDetailsCreatedLabel,
                  _formatDate(context, collection.createdAt),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  context,
                  l10n.collectionDetailsUpdatedLabel,
                  _formatDate(context, collection.updatedAt),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: l10n.collectionsEditAction,
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
        loading: () => LoadingView(message: l10n.collectionDetailsLoading),
        error: (error, _) =>
            ErrorView(message: l10n.collectionsErrorLoading('$error')),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(value);
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
