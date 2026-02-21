import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../view_models/collections_view_model.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_grid_tile.dart';
import '../widgets/empty_collections_view.dart';

enum _CollectionsViewMode { list, grid }

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  _CollectionsViewMode _viewMode = _CollectionsViewMode.list;

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        actions: [
          IconButton(
            tooltip: _viewMode == _CollectionsViewMode.list
                ? 'Switch to grid'
                : 'Switch to list',
            icon: Icon(
              _viewMode == _CollectionsViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_agenda_rounded,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == _CollectionsViewMode.list
                    ? _CollectionsViewMode.grid
                    : _CollectionsViewMode.list;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/statistics'),
          ),
        ],
      ),
      body: AppAnimatedSwitcher(
        duration: AppMotion.medium,
        child: collectionsAsync.when(
          data: (collections) {
            if (collections.isEmpty) {
              return const EmptyCollectionsView(key: ValueKey('empty'));
            }

            return RefreshIndicator(
              key: const ValueKey('data'),
              onRefresh: () async {
                ref.invalidate(collectionsViewModelProvider);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1160
                      ? 4
                      : constraints.maxWidth > 860
                      ? 3
                      : 2;
                  final totalItems = collections
                      .map((collection) => collection.itemCount)
                      .fold<int>(0, (sum, value) => sum + value);

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: AppCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _Metric(
                                    label: 'Collections',
                                    value: '${collections.length}',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 38,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                Expanded(
                                  child: _Metric(
                                    label: 'Items',
                                    value: '$totalItems',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_viewMode == _CollectionsViewMode.list)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxl * 2,
                          ),
                          sliver: SliverList.builder(
                            itemCount: collections.length,
                            itemBuilder: (context, index) {
                              final collection = collections[index];
                              return AppReveal(
                                delay: AppMotion.stagger * index,
                                child: CollectionCard(
                                  collection: collection,
                                  onTap: () => context.push(
                                    '/collections/${collection.id}',
                                  ),
                                  onEdit: () => context.push(
                                    '/collections/${collection.id}/edit',
                                  ),
                                  onDelete: () => _showDeleteDialog(
                                    context,
                                    ref,
                                    collection,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxl * 2,
                          ),
                          sliver: SliverGrid.builder(
                            itemCount: collections.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                  childAspectRatio: 0.88,
                                ),
                            itemBuilder: (context, index) {
                              final collection = collections[index];
                              return AppReveal(
                                delay: AppMotion.stagger * index,
                                beginOffsetY: 0.02,
                                beginScale: 0.96,
                                child: CollectionGridTile(
                                  collection: collection,
                                  onTap: () => context.push(
                                    '/collections/${collection.id}',
                                  ),
                                  onEdit: () => context.push(
                                    '/collections/${collection.id}/edit',
                                  ),
                                  onDelete: () => _showDeleteDialog(
                                    context,
                                    ref,
                                    collection,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, stack) => ErrorView(
            key: const ValueKey('error'),
            message: 'Error loading collections: $error',
            onRetry: () => ref.invalidate(collectionsViewModelProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/collections/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Collection'),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: const Text('Delete Collection'),
      content: Text(
        'Delete "${collection.name}" and ${collection.itemCount} items in this collection?',
      ),
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

    if (confirmed != true || !context.mounted) return;

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

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
