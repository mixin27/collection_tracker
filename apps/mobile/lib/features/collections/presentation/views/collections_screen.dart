import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../../../core/providers/providers.dart';
import '../../../../l10n/l10n.dart';
import '../view_models/collections_view_model.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_grid_tile.dart';
import '../widgets/empty_collections_view.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final collectionsAsync = ref.watch(collectionsViewModelProvider);
    final viewMode = ref.watch(collectionsViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collectionsTitle),
        actions: [
          IconButton(
            tooltip: viewMode == CollectionsViewMode.list
                ? l10n.actionSwitchToGrid
                : l10n.actionSwitchToList,
            icon: Icon(
              viewMode == CollectionsViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_agenda_rounded,
            ),
            onPressed: () =>
                ref.read(collectionsViewModeProvider.notifier).toggle(),
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
                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  final gridTileHeight = switch (crossAxisCount) {
                    4 => 264.0,
                    3 => 250.0,
                    _ =>
                      constraints.maxWidth < 390 || textScale > 1.0
                          ? 240.0
                          : 254.0,
                  };
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
                                    label: l10n.collectionsCountLabel,
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
                                    label: l10n.itemsCountLabel,
                                    value: '$totalItems',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (viewMode == CollectionsViewMode.list)
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
                                  mainAxisExtent: gridTileHeight,
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
            message: context.l10n.collectionsErrorLoading('$error'),
            onRetry: () => ref.invalidate(collectionsViewModelProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/collections/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.collectionsNewButton),
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
      title: Text(context.l10n.collectionsDeleteTitle),
      content: Text(
        context.l10n.collectionsDeleteMessage(
          collection.name,
          collection.itemCount,
        ),
      ),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: context.l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
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
          content: Text(context.l10n.collectionsDeleted(collection.name)),
          action: SnackBarAction(
            label: context.l10n.actionDismiss,
            onPressed: () {},
          ),
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
