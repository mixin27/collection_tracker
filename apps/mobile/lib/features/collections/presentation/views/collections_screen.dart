import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/empty_collections_view.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: const EmptyCollectionsView(),
    );
  }
}
