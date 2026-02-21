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

    return SafeArea(
      top: false,
      child: Container(
        height: height ?? tokens.navBarHeight,
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
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
          child: Column(
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
                  size: 20,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
