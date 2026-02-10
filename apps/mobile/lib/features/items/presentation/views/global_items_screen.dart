import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/global_items_view_model.dart';
import '../widgets/item_card.dart';

enum GlobalItemsType { favorites, wishlist }

class GlobalItemsScreen extends ConsumerWidget {
  const GlobalItemsScreen({required this.type, super.key});

  final GlobalItemsType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == GlobalItemsType.favorites ? 'Favorites' : 'Wishlist';
    final streamProvider = type == GlobalItemsType.favorites
        ? allFavoriteItemsProvider
        : allWishlistItemsProvider;

    final AsyncValue<List<Item>> itemsAsync = ref.watch(streamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == GlobalItemsType.favorites
                        ? Icons.favorite_border
                        : Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type == GlobalItemsType.favorites
                        ? 'No favorite items yet'
                        : 'Your wishlist is empty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          // Using a simple list view for now, effectively reusing the ItemCard
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final heroTag =
                  '${type == GlobalItemsType.favorites ? 'favorites' : 'wishlist'}_${item.id}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ItemCard(
                  item: item,
                  heroTag: heroTag,
                  onTap: () => context.pushNamed(
                    'item-detail',
                    pathParameters: {'id': item.id},
                    queryParameters: {'heroTag': heroTag},
                  ),
                  onDelete: () {}, // No delete from global list for now
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
