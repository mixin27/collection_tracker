import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

class ItemGridCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemGridCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showMenu(context),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'item_${item.id}',
                    child: _buildImage(theme),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.condition != null)
                        Text(
                          item.condition!.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.favorite, size: 20, color: Colors.red[400]),
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
              Icons.image_not_supported,
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
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(
          Icons.image_not_supported,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
