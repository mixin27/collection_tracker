import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class EmptyCollectionsView extends StatelessWidget {
  const EmptyCollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.collections_bookmark_outlined,
      title: 'No Collections Yet',
      message: 'Start organizing your items by creating your first collection.',
      action: AppButton(
        label: 'Create Collection',
        icon: const Icon(Icons.add),
        onPressed: () => context.push('/collections/create'),
      ),
    );
  }
}
