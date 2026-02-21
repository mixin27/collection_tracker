import 'dart:io';

import 'package:collection_tracker/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

class ItemGridCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String? heroTag;

  const ItemGridCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conditionColor = item.condition == null
        ? theme.colorScheme.onSurfaceVariant
        : _conditionColor(item.condition!);
    final effectiveValue = item.currentValue ?? item.purchasePrice;

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      onLongPress: () => _showMenu(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag ?? 'item_${item.id}',
                    child: _buildImage(theme),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.38),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isWishlist)
                          _IconBubble(
                            icon: Icons.bookmark_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        if (item.isFavorite)
                          _IconBubble(
                            icon: Icons.favorite_rounded,
                            color: Colors.red[400] ?? Colors.red,
                          ),
                        _IconBubble(
                          icon: Icons.more_horiz_rounded,
                          color: theme.colorScheme.onSurface,
                          onTap: () => _showMenu(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (item.condition != null)
                          _Pill(
                            icon: Icons.verified_outlined,
                            label: _conditionLabel(context, item.condition!),
                            color: conditionColor,
                          ),
                        if (item.quantity > 1)
                          _Pill(
                            icon: Icons.layers_outlined,
                            label: context.l10n.itemsQuantityShort(
                              item.quantity,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        if (item.tags.isNotEmpty)
                          _Pill(
                            icon: Icons.sell_outlined,
                            label: '#${item.tags.first}',
                            color: theme.colorScheme.onSurfaceVariant,
                            onTap: () => context.pushNamed(
                              'tag-items',
                              queryParameters: {'tag': item.tags.first},
                            ),
                          ),
                      ],
                    ),
                    if (effectiveValue != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _formatCurrency(context, effectiveValue),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (item.coverImagePath != null) {
      return Image.file(
        File(item.coverImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    } else if (item.coverImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => Icon(
          Icons.image_not_supported_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
  }

  void _showMenu(BuildContext context) {
    showAppSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(context.l10n.actionEdit),
              onTap: () {
                Navigator.pop(context);
                context.push('/items/${item.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                context.l10n.actionDelete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Color _conditionColor(ItemCondition condition) {
    return switch (condition) {
      ItemCondition.mint => const Color(0xFF199A6C),
      ItemCondition.good => const Color(0xFF2D6CDF),
      ItemCondition.fair => const Color(0xFFD96B12),
      ItemCondition.poor => const Color(0xFFD64545),
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

  String _formatCurrency(BuildContext context, double value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.simpleCurrency(locale: locale).format(value);
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 104),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconBubble({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubble = Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Icon(icon, size: 16, color: color),
    );

    if (onTap == null) return bubble;
    return GestureDetector(onTap: onTap, child: bubble);
  }
}
