import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'glass_surface.dart';

class GlassNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const GlassNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class GlassSegmentedNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<GlassNavDestination> destinations;
  final EdgeInsetsGeometry? margin;
  final double? height;

  const GlassSegmentedNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
    this.margin,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesignTokens>() ?? const DesignTokens();
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final effectiveHeight =
        (height ?? tokens.navBarHeight) +
        (textScale > 1 ? (textScale - 1) * 24 : 0);

    return SafeArea(
      top: false,
      child: Container(
        height: effectiveHeight,
        margin:
            margin ??
            EdgeInsets.fromLTRB(
              tokens.navBarHorizontalPadding,
              AppSpacing.sm,
              tokens.navBarHorizontalPadding,
              tokens.navBarBottomMargin,
            ),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: _GlassNavItem(
                  destination: destination,
                  selected: selected,
                  onTap: () => onDestinationSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final GlassNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final iconSize = textScale > 1.1 ? 18.0 : 20.0;
    final labelSize = textScale > 1.1 ? 10.5 : 11.0;
    final maxTextScale = math.min(textScale, 1.15);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        ),
        child: AnimatedScale(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          scale: selected ? 1 : 0.97,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTight =
                  constraints.maxHeight < 52 || constraints.maxWidth < 76;
              final showLabel = !isTight || textScale <= 1.02;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: AppMotion.fast,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      key: ValueKey<bool>(selected),
                      size: iconSize,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showLabel) ...[
                    SizedBox(height: isTight ? 2 : 3),
                    Flexible(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(maxTextScale),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: labelSize,
                          height: 1.0,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
