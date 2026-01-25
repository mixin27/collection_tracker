import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/statistics_view_model.dart';
import '../widgets/chart_card.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(statisticsViewModelProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: statisticsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(statisticsViewModelProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Collections',
                      value: '${stats.totalCollections}',
                      icon: Icons.collections_bookmark,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Items',
                      value: '${stats.totalItems}',
                      icon: Icons.inventory_2,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Favorites',
                      value: '${stats.favoriteItems}',
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Value',
                      value: '\$${stats.totalValue.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Items by Type Chart
              if (stats.itemsByType.isNotEmpty) ...[
                Text(
                  'Items by Collection Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ChartCard(
                  data: stats.itemsByType.entries.map((e) {
                    return ChartData(
                      label: _getTypeName(e.key),
                      value: e.value.toDouble(),
                      color: _getTypeColor(e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Items by Condition
              if (stats.itemsByCondition.isNotEmpty) ...[
                Text(
                  'Items by Condition',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ChartCard(
                  data: stats.itemsByCondition.entries.map((e) {
                    return ChartData(
                      label: e.key.name.toUpperCase(),
                      value: e.value.toDouble(),
                      color: _getConditionColor(e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Largest Collection
              if (stats.largestCollection != null) ...[
                Text(
                  'Largest Collection',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(
                      _getTypeIcon(stats.largestCollection!.type),
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      stats.largestCollection!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${stats.largestCollection!.itemCount} items',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Collections
              if (stats.recentCollections.isNotEmpty) ...[
                Text(
                  'Recent Collections',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...stats.recentCollections.map((collection) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_getTypeIcon(collection.type)),
                      title: Text(collection.name),
                      subtitle: Text(
                        '${collection.itemCount} items • Created ${_formatDate(collection.createdAt)}',
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading statistics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(statisticsViewModelProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(CollectionType type) {
    switch (type) {
      case CollectionType.book:
        return 'Books';
      case CollectionType.game:
        return 'Games';
      case CollectionType.movie:
        return 'Movies';
      case CollectionType.comic:
        return 'Comics';
      case CollectionType.music:
        return 'Music';
      case CollectionType.custom:
        return 'Custom';
    }
  }

  IconData _getTypeIcon(CollectionType type) {
    switch (type) {
      case CollectionType.book:
        return Icons.book;
      case CollectionType.game:
        return Icons.videogame_asset;
      case CollectionType.movie:
        return Icons.movie;
      case CollectionType.comic:
        return Icons.menu_book;
      case CollectionType.music:
        return Icons.album;
      case CollectionType.custom:
        return Icons.category;
    }
  }

  Color _getTypeColor(CollectionType type) {
    switch (type) {
      case CollectionType.book:
        return Colors.blue;
      case CollectionType.game:
        return Colors.purple;
      case CollectionType.movie:
        return Colors.red;
      case CollectionType.comic:
        return Colors.orange;
      case CollectionType.music:
        return Colors.pink;
      case CollectionType.custom:
        return Colors.grey;
    }
  }

  Color _getConditionColor(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.mint:
        return Colors.green;
      case ItemCondition.good:
        return Colors.blue;
      case ItemCondition.fair:
        return Colors.orange;
      case ItemCondition.poor:
        return Colors.red;
    }
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
}
