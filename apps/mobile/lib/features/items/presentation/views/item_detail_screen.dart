import 'dart:io';
import 'dart:math' as math;

import 'package:collection_tracker/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../providers/price_tracking_provider.dart';
import '../view_models/items_view_model.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  final String? heroTag;

  const ItemDetailScreen({required this.itemId, this.heroTag, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.itemDetailNotFoundTitle,
              message: l10n.itemDetailNotFoundMessage,
            ),
          );
        }

        final theme = Theme.of(context);
        final priceHistoryAsync = ref.watch(itemPriceHistoryProvider(item.id));
        final effectiveValue = item.currentValue ?? item.purchasePrice;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: l10n.actionEdit,
                onPressed: () => context.push('/items/${item.id}/edit'),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _ItemHeroBanner(
                item: item,
                heroTag: heroTag,
                effectiveValue: effectiveValue,
                formatCurrency: (value) => _formatCurrency(context, value),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppReveal(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (item.description != null &&
                                item.description!.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                item.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _QuickActionChip(
                                  icon: item.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  label: item.isFavorite
                                      ? l10n.itemDetailFavorited
                                      : l10n.itemDetailFavorite,
                                  active: item.isFavorite,
                                  onTap: () =>
                                      ref.read(toggleFavoriteProvider(item)),
                                ),
                                _QuickActionChip(
                                  icon: item.isWishlist
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  label: item.isWishlist
                                      ? l10n.itemDetailInWishlist
                                      : l10n.navWishlist,
                                  active: item.isWishlist,
                                  onTap: () =>
                                      ref.read(toggleWishlistProvider(item)),
                                ),
                                _QuickActionChip(
                                  icon: Icons.edit_rounded,
                                  label: l10n.actionEdit,
                                  onTap: () =>
                                      context.push('/items/${item.id}/edit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppReveal(
                        delay: AppMotion.stagger,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.itemsTagsTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AnimatedSize(
                                duration: AppMotion.medium,
                                curve: AppMotion.emphasized,
                                child: Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: item.tags
                                      .map(
                                        (tag) => ActionChip(
                                          label: Text(tag),
                                          backgroundColor: theme
                                              .colorScheme
                                              .secondaryContainer,
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
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppReveal(
                      delay: AppMotion.stagger * 2,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.itemDetailPriceTrackingTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                AppButton(
                                  label: l10n.actionUpdate,
                                  icon: const Icon(Icons.show_chart, size: 18),
                                  variant: AppButtonVariant.ghost,
                                  onPressed: () =>
                                      _showUpdateCurrentValueDialog(
                                        context,
                                        ref,
                                        item,
                                      ),
                                ),
                              ],
                            ),
                            if (effectiveValue != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _formatCurrency(context, effectiveValue),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (item.purchasePrice != null &&
                                  item.currentValue != null) ...[
                                const SizedBox(height: 4),
                                _ValueDelta(
                                  purchasePrice: item.purchasePrice!,
                                  currentValue: item.currentValue!,
                                  formatCurrency: (value) =>
                                      _formatCurrency(context, value),
                                ),
                              ],
                            ] else ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.itemDetailNoValueMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            AppAnimatedSwitcher(
                              child: priceHistoryAsync.when(
                                data: (history) {
                                  if (history.isEmpty) {
                                    return Text(
                                      l10n.itemDetailNoHistoryMessage,
                                      key: const ValueKey('history-empty'),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    );
                                  }

                                  final recent = history.reversed
                                      .take(5)
                                      .toList();
                                  return Column(
                                    key: const ValueKey('history-data'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _PriceHistoryChart(points: history),
                                      const SizedBox(height: AppSpacing.md),
                                      ...recent.map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.xs,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                _formatDate(context, entry.$1),
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                              const Spacer(),
                                              Text(
                                                _formatCurrency(
                                                  context,
                                                  entry.$2,
                                                ),
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                  height: 84,
                                  child: LoadingView(indicatorSize: 36),
                                ),
                                error: (_, _) => Text(
                                  l10n.itemDetailPriceHistoryError,
                                  key: const ValueKey('history-error'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppReveal(
                      delay: AppMotion.stagger * 3,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.itemDetailDetailsTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (item.barcode != null)
                              _DetailRow(
                                icon: Icons.qr_code_rounded,
                                label: l10n.itemDetailBarcodeLabel,
                                value: item.barcode!,
                              ),
                            if (item.condition != null)
                              _DetailRow(
                                icon: Icons.verified_rounded,
                                label: l10n.itemDetailConditionLabel,
                                value: _conditionLabel(
                                  context,
                                  item.condition!,
                                ),
                              ),
                            _DetailRow(
                              icon: Icons.layers_rounded,
                              label: l10n.itemDetailQuantityLabel,
                              value: '${item.quantity}',
                            ),
                            if (item.location != null)
                              _DetailRow(
                                icon: Icons.location_on_rounded,
                                label: l10n.itemDetailLocationLabel,
                                value: item.location!,
                              ),
                            if (item.purchasePrice != null)
                              _DetailRow(
                                icon: Icons.attach_money_rounded,
                                label: l10n.itemDetailPurchasePriceLabel,
                                value: _formatCurrency(
                                  context,
                                  item.purchasePrice!,
                                ),
                              ),
                            if (item.currentValue != null)
                              _DetailRow(
                                icon: Icons.show_chart_rounded,
                                label: l10n.itemDetailCurrentValueLabel,
                                value: _formatCurrency(
                                  context,
                                  item.currentValue!,
                                ),
                              ),
                            if (item.purchaseDate != null)
                              _DetailRow(
                                icon: Icons.event_rounded,
                                label: l10n.itemDetailPurchaseDateLabel,
                                value: _formatDate(context, item.purchaseDate!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (item.notes != null &&
                        item.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppReveal(
                        delay: AppMotion.stagger * 4,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.itemDetailNotesTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                item.notes!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.35,
                                ),
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
      loading: () =>
          Scaffold(body: LoadingView(message: l10n.itemDetailLoadingMessage)),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: l10n.itemDetailErrorLoading('$error'),
          onRetry: () => ref.invalidate(itemDetailProvider(itemId)),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(date);
  }

  String _formatCurrency(BuildContext context, double value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.simpleCurrency(locale: locale).format(value);
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

  Future<void> _showUpdateCurrentValueDialog(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final l10n = context.l10n;
    var draftValue = item.currentValue?.toStringAsFixed(2) ?? '';

    final value = await showAppDialog<double>(
      context: context,
      title: Text(l10n.itemDetailUpdateValueTitle),
      content: AppInput(
        initialValue: draftValue,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        labelText: l10n.itemDetailCurrentValueLabel,
        prefixText: NumberFormat.simpleCurrency(
          locale: Localizations.localeOf(context).toLanguageTag(),
        ).currencySymbol,
        hintText: '0.00',
        onChanged: (value) {
          draftValue = value;
        },
      ),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context),
        ),
        AppButton(
          label: l10n.actionSave,
          onPressed: () {
            final parsed = double.tryParse(draftValue.trim());
            if (parsed == null || parsed < 0) return;
            closeAppDialog(context, parsed);
          },
        ),
      ],
    );

    if (value == null || !context.mounted) return;

    try {
      await ref.read(
        updateItemProvider(item.copyWith(currentValue: value)).future,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.itemDetailCurrentValueUpdated)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemDetailUpdateValueFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ItemHeroBanner extends StatelessWidget {
  final Item item;
  final String? heroTag;
  final double? effectiveValue;
  final String Function(double value) formatCurrency;

  const _ItemHeroBanner({
    required this.item,
    required this.heroTag,
    required this.effectiveValue,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag ?? 'item_${item.id}', child: _buildCover(theme)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (item.condition != null)
                  _HeroBadge(
                    icon: Icons.verified_rounded,
                    label: switch (item.condition!) {
                      ItemCondition.mint => context.l10n.itemConditionMint,
                      ItemCondition.good => context.l10n.itemConditionGood,
                      ItemCondition.fair => context.l10n.itemConditionFair,
                      ItemCondition.poor => context.l10n.itemConditionPoor,
                    },
                  ),
                if (item.quantity > 1)
                  _HeroBadge(
                    icon: Icons.layers_rounded,
                    label: context.l10n.itemsQuantityShort(item.quantity),
                  ),
                if (effectiveValue != null)
                  _HeroBadge(
                    icon: Icons.attach_money_rounded,
                    label: formatCurrency(effectiveValue!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(ThemeData theme) {
    if (item.coverImagePath != null) {
      return Image.file(
        File(item.coverImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(theme),
      );
    } else if (item.coverImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const LoadingView(indicatorSize: 38),
        errorWidget: (context, url, error) => _fallback(theme),
      );
    } else {
      return _fallback(theme);
    }
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_rounded,
        size: 76,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: active
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueDelta extends StatelessWidget {
  final double purchasePrice;
  final double currentValue;
  final String Function(double value) formatCurrency;

  const _ValueDelta({
    required this.purchasePrice,
    required this.currentValue,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (purchasePrice == 0) return const SizedBox.shrink();
    final delta = currentValue - purchasePrice;
    final ratio = (delta / purchasePrice) * 100;
    final isPositive = delta >= 0;
    final color = isPositive
        ? const Color(0xFF199A6C)
        : const Color(0xFFD64545);

    return Row(
      children: [
        Icon(
          isPositive ? Icons.north_east_rounded : Icons.south_east_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${formatCurrency(delta.abs())} (${ratio.toStringAsFixed(1)}%)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidth = math.min(132.0, MediaQuery.sizeOf(context).width * 0.34);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
