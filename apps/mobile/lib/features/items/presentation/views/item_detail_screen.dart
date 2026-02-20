import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/price_tracking_provider.dart';
import '../view_models/items_view_model.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  final String? heroTag;

  const ItemDetailScreen({required this.itemId, this.heroTag, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Item not found')),
          );
        }

        final theme = Theme.of(context);
        final priceHistoryAsync = ref.watch(itemPriceHistoryProvider(item.id));

        return Scaffold(
          appBar: AppBar(
            title: Text(item.title),
            actions: [
              IconButton(
                tooltip: 'Add to favorites',
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  ref.read(toggleFavoriteProvider(item));
                },
              ),
              IconButton(
                tooltip: 'Add to wishlist',
                icon: Icon(
                  item.isWishlist ? Icons.bookmark : Icons.bookmark_border,
                  color: item.isWishlist ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  ref.read(toggleWishlistProvider(item));
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit item',
                onPressed: () {
                  context.push('/items/${item.id}/edit');
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              // Cover Image
              if (item.coverImagePath != null)
                Hero(
                  tag: heroTag ?? 'item_${item.id}',
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.file(
                      File(item.coverImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else if (item.coverImageUrl != null)
                Hero(
                  tag: heroTag ?? 'item_${item.id}',
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: item.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Hero(
                  tag: heroTag ?? 'item_${item.id}',
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item.description!, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                    ],

                    if (item.tags.isNotEmpty) ...[
                      Text(
                        'Tags',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.tags
                              .map(
                                (tag) => ActionChip(
                                  label: Text(tag),
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
                      const SizedBox(height: 16),
                    ],

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Price Tracking',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showUpdateCurrentValueDialog(
                                        context,
                                        ref,
                                        item,
                                      ),
                                  icon: const Icon(Icons.show_chart),
                                  label: const Text('Update'),
                                ),
                              ],
                            ),
                            if (item.currentValue != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(item.currentValue!),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 4),
                              Text(
                                'No current value set',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            priceHistoryAsync.when(
                              data: (history) {
                                if (history.isEmpty) {
                                  return Text(
                                    'No historical points yet. Update current value to start tracking.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                }

                                final recent = history.reversed
                                    .take(5)
                                    .toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PriceHistoryChart(points: history),
                                    const SizedBox(height: 12),
                                    ...recent.map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _formatDate(entry.$1),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatCurrency(entry.$2),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading: () => const SizedBox(
                                height: 80,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              error: (_, _) => Text(
                                'Unable to load price history',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (item.barcode != null)
                              _DetailRow(
                                label: 'Barcode',
                                value: item.barcode!,
                              ),
                            if (item.condition != null)
                              _DetailRow(
                                label: 'Condition',
                                value: item.condition!.name.toUpperCase(),
                              ),
                            _DetailRow(
                              label: 'Quantity',
                              value: '${item.quantity}',
                            ),
                            if (item.location != null)
                              _DetailRow(
                                label: 'Location',
                                value: item.location!,
                              ),
                            if (item.purchasePrice != null)
                              _DetailRow(
                                label: 'Purchase Price',
                                value:
                                    '\$${item.purchasePrice!.toStringAsFixed(2)}',
                              ),
                            if (item.currentValue != null)
                              _DetailRow(
                                label: 'Current Value',
                                value:
                                    '\$${item.currentValue!.toStringAsFixed(2)}',
                              ),
                            if (item.purchaseDate != null)
                              _DetailRow(
                                label: 'Purchase Date',
                                value: _formatDate(item.purchaseDate!),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Notes
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.notes!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  Future<void> _showUpdateCurrentValueDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    var draftValue = item.currentValue?.toStringAsFixed(2) ?? '';

    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Current Value'),
        content: TextFormField(
          initialValue: draftValue,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Current value',
            prefixText: '\$',
            hintText: '0.00',
          ),
          onChanged: (value) {
            draftValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(draftValue.trim());
              if (parsed == null || parsed < 0) return;
              Navigator.pop(context, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (value == null || !context.mounted) return;

    try {
      await ref.read(
        updateItemProvider(item.copyWith(currentValue: value)).future,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Current value updated')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update value: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _PriceHistoryChart extends StatelessWidget {
  final List<(DateTime, double)> points;

  const _PriceHistoryChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _PriceHistoryPainter(
          points: points,
          lineColor: theme.colorScheme.primary,
          pointColor: theme.colorScheme.primaryContainer,
        ),
      ),
    );
  }
}

class _PriceHistoryPainter extends CustomPainter {
  final List<(DateTime, double)> points;
  final Color lineColor;
  final Color pointColor;

  _PriceHistoryPainter({
    required this.points,
    required this.lineColor,
    required this.pointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minY = points.map((e) => e.$2).reduce(math.min);
    final maxY = points.map((e) => e.$2).reduce(math.max);
    final yRange = (maxY - minY).abs() < 0.001 ? 1.0 : maxY - minY;
    final xStep = points.length == 1
        ? size.width
        : size.width / (points.length - 1);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withValues(alpha: 0.18), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = xStep * i;
      final normalizedY = (points[i].$2 - minY) / yRange;
      final y = size.height - (normalizedY * (size.height - 10)) - 5;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    final lastX = xStep * (points.length - 1);
    fillPath.lineTo(lastX, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()..color = pointColor;
    for (var i = 0; i < points.length; i++) {
      final x = xStep * i;
      final normalizedY = (points[i].$2 - minY) / yRange;
      final y = size.height - (normalizedY * (size.height - 10)) - 5;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PriceHistoryPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
