import 'package:domain/domain.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../view_models/global_items_view_model.dart';
import '../widgets/item_card.dart';

enum GlobalItemsType { favorites, wishlist }

class GlobalItemsScreen extends ConsumerWidget {
  const GlobalItemsScreen({required this.type, super.key});

  final GlobalItemsType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = type == GlobalItemsType.favorites
        ? l10n.navFavorites
        : l10n.navWishlist;
    final streamProvider = type == GlobalItemsType.favorites
        ? allFavoriteItemsProvider
        : allWishlistItemsProvider;

    final AsyncValue<List<Item>> itemsAsync = ref.watch(streamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppAnimatedSwitcher(
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                icon: type == GlobalItemsType.favorites
                    ? Icons.favorite_border
                    : Icons.bookmark_border,
                title: type == GlobalItemsType.favorites
                    ? l10n.globalItemsNoFavoritesTitle
                    : l10n.globalItemsNoWishlistTitle,
                message: type == GlobalItemsType.favorites
                    ? l10n.globalItemsNoFavoritesMessage
                    : l10n.globalItemsNoWishlistMessage,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final heroTag =
                    '${type == GlobalItemsType.favorites ? 'favorites' : 'wishlist'}_${item.id}';
                return AppReveal(
                  delay: AppMotion.stagger * index,
                  child: ItemCard(
                    item: item,
                    heroTag: heroTag,
                    onTap: () => context.pushNamed(
                      'item-detail',
                      pathParameters: {'id': item.id},
                      queryParameters: {'heroTag': heroTag},
                    ),
                    onDelete: () {},
                  ),
                );
              },
            );
          },
          loading: () => LoadingView(message: l10n.globalItemsLoading),
          error: (error, stack) =>
              ErrorView(message: l10n.globalItemsErrorLoading('$error')),
        ),
      ),
    );
  }
}
