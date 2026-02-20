import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String? heroTag;

  const ItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Row(
        children: [
          Hero(
            tag: heroTag ?? 'item_${item.id}',
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: _buildImage(theme),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isFavorite)
                      Icon(Icons.favorite, size: 20, color: Colors.red[400]),
                    if (item.isWishlist) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.bookmark,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.condition != null) ...[
                      _ConditionBadge(condition: item.condition!),
                      const SizedBox(width: 8),
                    ],
                    if (item.quantity > 1)
                      Text(
                        'Qty: ${item.quantity}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: AppMotion.medium,
                    curve: AppMotion.emphasized,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.tags
                          .take(3)
                          .map(
                            (tag) => ActionChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              onPressed: () => context.pushNamed(
                                'tag-items',
                                queryParameters: {'tag': tag},
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (item.currentValue != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '\$${item.currentValue!.toStringAsFixed(2)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    // Priority: local image > network image > placeholder
    if (item.coverImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(item.coverImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              color: theme.colorScheme.onSurfaceVariant,
            );
          },
        ),
      );
    } else if (item.coverImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: item.coverImageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(
            Icons.image_not_supported,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.image_not_supported,
        color: theme.colorScheme.onSurfaceVariant,
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
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                context.push('/items/${item.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
}

class _ConditionBadge extends StatelessWidget {
  final ItemCondition condition;

  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForCondition(condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        condition.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColorForCondition(ItemCondition condition) {
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
}
