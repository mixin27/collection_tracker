import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey('CollectionTrackerShell'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final destinations = _buildDestinations(context);

    if (size.width < 600) {
      return _GlassBottomShell(
        body: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: destinations,
      );
    }

    return _RailShell(
      body: navigationShell,
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: _goBranch,
      destinations: destinations,
      extended: size.width >= 1200,
    );
  }

  List<_ShellDestination> _buildDestinations(BuildContext context) {
    final l10n = context.l10n;
    return [
      _ShellDestination(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: l10n.navHome,
      ),
      _ShellDestination(
        icon: Icons.favorite_border,
        selectedIcon: Icons.favorite,
        label: l10n.navFavorites,
      ),
      _ShellDestination(
        icon: Icons.bookmark_border,
        selectedIcon: Icons.bookmark,
        label: l10n.navWishlist,
      ),
      _ShellDestination(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];
  }
}

class _ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _GlassBottomShell extends StatelessWidget {
  const _GlassBottomShell({
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesignTokens>() ?? const DesignTokens();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final navHeight =
        tokens.navBarHeight + (textScale > 1 ? (textScale - 1) * 18 : 0);
    final navReservedSpace =
        navHeight + tokens.navBarBottomMargin + bottomInset + 4;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(
                    bottom: media.padding.bottom + navReservedSpace,
                  ),
                  viewPadding: media.viewPadding.copyWith(
                    bottom: media.viewPadding.bottom + navReservedSpace,
                  ),
                ),
                child: body,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassSegmentedNavigationBar(
              height: navHeight,
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map(
                    (destination) => GlassNavDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: destination.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailShell extends StatelessWidget {
  const _RailShell({
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
            child: SizedBox(
              width: extended ? 242 : 96,
              child: GlassSurface(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  extended: extended,
                  backgroundColor: Colors.transparent,
                  indicatorColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  selectedIconTheme: IconThemeData(
                    color: theme.colorScheme.primary,
                  ),
                  selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  unselectedLabelTextStyle: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        if (extended) ...[
                          Text(
                            'Collection',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tracker',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: destinations
                      .map(
                        (destination) => NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: body),
        ],
      ),
    );
  }
}
