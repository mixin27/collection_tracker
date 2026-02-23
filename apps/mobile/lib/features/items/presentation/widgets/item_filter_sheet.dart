import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../../../l10n/l10n.dart';
import '../providers/items_filter_provider.dart';
import '../view_models/items_view_model.dart';

class ItemFilterSheet extends ConsumerWidget {
  final String collectionId;

  const ItemFilterSheet({required this.collectionId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(itemFilterProvider);
    final notifier = ref.read(itemFilterProvider.notifier);
    final itemsAsync = ref.watch(itemsListProvider(collectionId));
    final theme = Theme.of(context);
    final availableTags = itemsAsync.maybeWhen(
      data: (items) {
        final tags = items.expand((item) => item.tags).toSet().toList()..sort();
        return tags;
      },
      orElse: () => const <String>[],
    );

    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemsFilterTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppButton(
                  label: l10n.actionReset,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => notifier.reset(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sort By Section
            Text(
              l10n.itemsSortByTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ItemSortBy.values.map((option) {
                final isSelected = filter.sortBy == option;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_sortLabel(context, option)),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(
                          filter.sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => notifier.setSortBy(option),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Favorites Section
            SwitchListTile(
              title: Text(l10n.itemsFilterFavoritesOnly),
              value: filter.showOnlyFavorites,
              onChanged: (_) => notifier.toggleFavorites(),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l10n.itemsFilterWishlistOnly),
              value: filter.showOnlyWishlist,
              onChanged: (_) => notifier.toggleWishlist(),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Conditions Section
            Text(
              l10n.itemsFilterConditionsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ItemCondition.values.map((condition) {
                final isSelected = filter.conditions.contains(condition);
                return FilterChip(
                  label: Text(_conditionLabel(context, condition)),
                  selected: isSelected,
                  onSelected: (_) => notifier.toggleCondition(condition),
                );
              }).toList(),
            ),
            if (availableTags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.itemsTagsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) {
                    final isSelected = filter.tags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => notifier.toggleTag(tag),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.actionApply,
                expand: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _sortLabel(BuildContext context, ItemSortBy sortBy) {
    final l10n = context.l10n;
    return switch (sortBy) {
      ItemSortBy.custom => l10n.itemSortCustom,
      ItemSortBy.title => l10n.itemSortTitle,
      ItemSortBy.createdAt => l10n.itemSortCreatedAt,
      ItemSortBy.purchaseDate => l10n.itemSortPurchaseDate,
      ItemSortBy.currentValue => l10n.itemSortCurrentValue,
      ItemSortBy.quantity => l10n.itemSortQuantity,
    };
  }

  String _conditionLabel(BuildContext context, ItemCondition condition) {
    final l10n = context.l10n;
    return switch (condition) {
      ItemCondition.mint => l10n.itemConditionMint,
      ItemCondition.good => l10n.itemConditionGood,
      ItemCondition.fair => l10n.itemConditionFair,
      ItemCondition.poor => l10n.itemConditionPoor,
    };
  }
}
