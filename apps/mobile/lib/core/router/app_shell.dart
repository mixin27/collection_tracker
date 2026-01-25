import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

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

    // Standard material breakpoint for NavigationRail vs BottomNavigationBar
    if (size.width < 600) {
      return ScaffoldWithNavigationBar(
        body: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
      );
    } else {
      return ScaffoldWithNavigationRail(
        body: navigationShell,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        // Show extended rail on large desktop screens
        extended: size.width >= 1200,
      );
    }
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: onDestinationSelected,
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'home-scanner-fab',
      //   onPressed: () => context.push('/scanner'),
      //   child: const Icon(Icons.qr_code_scanner),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
    this.extended = false,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            extended: extended,
            // Add leading widget for app icon/logo
            leading: Column(
              children: [
                const SizedBox(height: 8),
                // Container(
                //   width: 48,
                //   height: 48,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     image: const DecorationImage(
                //       image: AssetImage('assets/images/logo.png'),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                if (extended) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Collection Tracker',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                // Can be used for primary action
                // FloatingActionButton(
                //   heroTag: 'home-scanner-fab',
                //   onPressed: () => context.push('/scanner'),
                //   child: const Icon(Icons.qr_code_scanner),
                // ),
                const SizedBox(height: 16),
              ],
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(child: body),
        ],
      ),
    );
  }
}
