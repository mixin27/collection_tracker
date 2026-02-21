import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../../collections/presentation/widgets/collection_visuals.dart';
import '../view_models/statistics_view_model.dart';
import '../widgets/chart_card.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: AppAnimatedSwitcher(
        child: statisticsAsync.when(
          data: (stats) {
            if (stats.totalCollections == 0) {
              return EmptyState(
                icon: Icons.insights_outlined,
                title: 'No statistics yet',
                message:
                    'Create a collection and add items to unlock portfolio insights.',
                action: AppButton(
                  label: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    ref.read(statisticsViewModelProvider.notifier).refresh();
                  },
                ),
              );
            }

            final favoritesRatio = stats.totalItems == 0
                ? 0.0
                : stats.favoriteItems / stats.totalItems;
            final wishlistRatio = stats.totalItems == 0
                ? 0.0
                : stats.wishlistItems / stats.totalItems;
            final pricedRatio = stats.totalItems == 0
                ? 0.0
                : stats.pricedItems / stats.totalItems;

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(statisticsViewModelProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  AppReveal(
                    child: _PortfolioValueCard(
                      totalValue: stats.totalValue,
                      averageValue: stats.averageItemValue,
                      pricedItems: stats.pricedItems,
                      totalItems: stats.totalItems,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppReveal(
                    delay: AppMotion.stagger,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(
                          context,
                        ).scale(1.0);
                        final width = constraints.maxWidth;
                        final isCompact = width < 900 || textScale > 1.05;
                        final crossAxisCount = isCompact ? 2 : 4;
                        final tileHeight = switch (crossAxisCount) {
                          2 => width < 460 || textScale > 1.0 ? 164.0 : 148.0,
                          _ => 136.0,
                        };
                        final cards = [
                          StatCard(
                            title: 'Collections',
                            value: '${stats.totalCollections}',
                            icon: Icons.collections_bookmark_rounded,
                            color: Colors.blue,
                          ),
                          StatCard(
                            title: 'Items',
                            value: '${stats.totalItems}',
                            icon: Icons.inventory_2_rounded,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'Quantity',
                            value: '${stats.totalQuantity}',
                            icon: Icons.layers_rounded,
                            color: Colors.indigo,
                          ),
                          StatCard(
                            title: 'Favorites',
                            value: '${stats.favoriteItems}',
                            subtitle:
                                '${(favoritesRatio * 100).toStringAsFixed(0)}% of items',
                            icon: Icons.favorite_rounded,
                            color: Colors.red,
                          ),
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: cards.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: AppSpacing.md,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisExtent: tileHeight,
                              ),
                          itemBuilder: (context, index) => cards[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppReveal(
                    delay: AppMotion.stagger * 2,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inventory Health',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ProgressLine(
                            label: 'Valuation coverage',
                            value: pricedRatio,
                            caption:
                                '${stats.pricedItems}/${stats.totalItems} priced',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ProgressLine(
                            label: 'Favorites coverage',
                            value: favoritesRatio,
                            caption:
                                '${stats.favoriteItems}/${stats.totalItems} favorites',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ProgressLine(
                            label: 'Wishlist coverage',
                            value: wishlistRatio,
                            caption:
                                '${stats.wishlistItems}/${stats.totalItems} wishlist',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (stats.itemsByType.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppReveal(
                      delay: AppMotion.stagger * 3,
                      child: Text(
                        'Items by Collection Type',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppReveal(
                      delay: AppMotion.stagger * 4,
                      child: ChartCard(
                        data: stats.itemsByType.entries.map((entry) {
                          return ChartData(
                            label: collectionTypeLabel(entry.key),
                            value: entry.value.toDouble(),
                            color: collectionTypeColor(context, entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (stats.itemsByCondition.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppReveal(
                      delay: AppMotion.stagger * 5,
                      child: Text(
                        'Items by Condition',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppReveal(
                      delay: AppMotion.stagger * 6,
                      child: ChartCard(
                        data: stats.itemsByCondition.entries.map((entry) {
                          return ChartData(
                            label: entry.key.name.toUpperCase(),
                            value: entry.value.toDouble(),
                            color: _getConditionColor(entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (stats.topValuedCollections.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppReveal(
                      delay: AppMotion.stagger * 7,
                      child: Text(
                        'Top Valued Collections',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...stats.topValuedCollections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final collection = entry.value.$1;
                      final value = entry.value.$2;
                      return AppReveal(
                        delay: AppMotion.stagger * (8 + index),
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          onTap: () =>
                              context.go('/collections/${collection.id}'),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.12),
                                child: Text('#${index + 1}'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      collection.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      '${collection.itemCount} items',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatCurrency(value),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  if (stats.largestCollection != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppReveal(
                      delay: AppMotion.stagger * 9,
                      child: Text(
                        'Largest Collection',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppReveal(
                      delay: AppMotion.stagger * 10,
                      child: AppCard(
                        onTap: () => context.go(
                          '/collections/${stats.largestCollection!.id}',
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            collectionTypeIcon(stats.largestCollection!.type),
                            size: 34,
                            color: collectionTypeColor(
                              context,
                              stats.largestCollection!.type,
                            ),
                          ),
                          title: Text(
                            stats.largestCollection!.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${stats.largestCollection!.itemCount} items',
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (stats.recentCollections.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppReveal(
                      delay: AppMotion.stagger * 11,
                      child: Text(
                        'Recently Created',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...stats.recentCollections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final collection = entry.value;
                      return AppReveal(
                        delay: AppMotion.stagger * (12 + index),
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          onTap: () =>
                              context.go('/collections/${collection.id}'),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              collectionTypeIcon(collection.type),
                              color: collectionTypeColor(
                                context,
                                collection.type,
                              ),
                            ),
                            title: Text(collection.name),
                            subtitle: Text(
                              '${collection.itemCount} items • Created ${_formatDate(collection.createdAt)}',
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
          loading: () => const LoadingView(
            key: ValueKey('stats-loading'),
            message: 'Calculating portfolio insights...',
          ),
          error: (error, stack) => ErrorView(
            key: const ValueKey('stats-error'),
            message: 'Error loading statistics: $error',
            onRetry: () => ref.invalidate(statisticsViewModelProvider),
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(ItemCondition condition) {
    return switch (condition) {
      ItemCondition.mint => const Color(0xFF199A6C),
      ItemCondition.good => const Color(0xFF2D6CDF),
      ItemCondition.fair => const Color(0xFFD96B12),
      ItemCondition.poor => const Color(0xFFD64545),
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else {
      return '${(diff.inDays / 365).floor()} years ago';
    }
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

class _PortfolioValueCard extends StatelessWidget {
  final double totalValue;
  final double averageValue;
  final int pricedItems;
  final int totalItems;

  const _PortfolioValueCard({
    required this.totalValue,
    required this.averageValue,
    required this.pricedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg - 1),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.18),
              theme.colorScheme.primary.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Value',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '\$${totalValue.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Badge(
                  text: 'Avg priced item: \$${averageValue.toStringAsFixed(2)}',
                ),
                _Badge(text: '$pricedItems / $totalItems items priced'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final String caption;
  final double value;

  const _ProgressLine({
    required this.label,
    required this.caption,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '${(clamped * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: TweenAnimationBuilder<double>(
            duration: AppMotion.slow,
            tween: Tween(begin: 0, end: clamped),
            builder: (context, animated, _) =>
                LinearProgressIndicator(value: animated, minHeight: 7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
