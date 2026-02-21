import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

import 'collection_visuals.dart';

class CollectionGridTile extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CollectionGridTile({
    required this.collection,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = collectionTypeColor(context, collection.type);

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      onLongPress: () => _showActions(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 250;
          final hasDescription =
              collection.description != null &&
              collection.description!.trim().isNotEmpty;
          final iconSize = compact ? 36.0 : 40.0;

          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg - 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    compact ? AppSpacing.sm : AppSpacing.md,
                    AppSpacing.xs,
                    compact ? AppSpacing.sm : AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.25),
                        accent.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'collection_${collection.id}',
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.92,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Icon(
                            collectionTypeIcon(collection.type),
                            color: accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Collection actions',
                        onPressed: () => _showActions(context),
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      compact ? AppSpacing.xs : AppSpacing.sm,
                      AppSpacing.md,
                      compact ? AppSpacing.sm : AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(
                          height: compact ? AppSpacing.xs : AppSpacing.sm,
                        ),
                        _Pill(
                          icon: Icons.inventory_2_outlined,
                          label: '${collection.itemCount} items',
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _Pill(
                          icon: Icons.category_outlined,
                          label: collectionTypeLabel(collection.type),
                        ),
                        if (hasDescription) ...[
                          if (!compact) const Spacer(),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            collection.description!,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showActions(BuildContext context) {
    HapticFeedback.lightImpact();
    showAppSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Open Collection'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Collection'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                HapticFeedback.lightImpact();
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
