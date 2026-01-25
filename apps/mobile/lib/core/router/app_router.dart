import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/collections/presentation/views/collection_detail_screen.dart';
import '../../features/collections/presentation/views/collections_screen.dart';
import '../../features/collections/presentation/views/create_collection_screen.dart';
import '../../features/collections/presentation/views/edit_collection_screen.dart';
import '../../features/items/presentation/views/add_item_screen.dart';
import '../../features/items/presentation/views/edit_item_screen.dart';
import '../../features/items/presentation/views/item_detail_screen.dart';
import '../../features/items/presentation/views/items_screen.dart';
import '../../features/scanner/presentation/views/scanner_screen.dart';
import '../../features/search/presentation/views/search_screen.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/collections',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.collections,
                name: 'collections',
                builder: (_, _) => const CollectionsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create-collection',
                    builder: (context, state) => const CreateCollectionScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'collection-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CollectionDetailScreen(collectionId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'edit-collection',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EditCollectionScreen(collectionId: id);
                        },
                      ),
                      GoRoute(
                        path: 'items',
                        name: 'items',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ItemsScreen(collectionId: id);
                        },
                      ),
                      GoRoute(
                        path: 'search',
                        name: 'search',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return SearchScreen(collectionId: id);
                        },
                      ),
                      GoRoute(
                        path: 'add-item',
                        name: 'add-item',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AddItemScreen(collectionId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                name: 'settings',
                builder: (_, _) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/items/:id',
        name: 'item-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-item',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EditItemScreen(itemId: id);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) {
          final collectionId = state.uri.queryParameters['collectionId'];
          return ScannerScreen(collectionId: collectionId);
        },
      ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/collections'),
              child: const Text('Go to Collections'),
            ),
          ],
        ),
      ),
    ),
  );
}
