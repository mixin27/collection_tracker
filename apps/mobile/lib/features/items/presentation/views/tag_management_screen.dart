import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/tag_management_view_model.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() =>
      _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isBusy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsWithUsageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tags')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Search tags...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: tagsAsync.when(
                data: (tags) {
                  final filtered = tags.where((entry) {
                    if (_query.isEmpty) return true;
                    return entry.$1.toLowerCase().contains(
                      _query.toLowerCase(),
                    );
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      key: const ValueKey('empty-tags'),
                      child: Text(
                        _query.isEmpty
                            ? 'No tags created yet'
                            : 'No tags match "$_query"',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.separated(
                    key: const ValueKey('tags-list'),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tag = filtered[index].$1;
                      final usage = filtered[index].$2;

                      return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                child: const Icon(Icons.sell_outlined),
                              ),
                              title: Text(tag),
                              subtitle: Text(
                                usage == 1
                                    ? 'Used in 1 item'
                                    : 'Used in $usage items',
                              ),
                              trailing: PopupMenuButton<_TagAction>(
                                onSelected: (action) =>
                                    _handleAction(action: action, tag: tag),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _TagAction.rename,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        Icons.drive_file_rename_outline,
                                      ),
                                      title: Text('Rename'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _TagAction.merge,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(Icons.merge_type),
                                      title: Text('Merge Into...'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _TagAction.delete,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(delay: (index * 35).ms)
                          .fadeIn(duration: 260.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.08, end: 0, duration: 260.ms);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load tags: $error'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction({
    required _TagAction action,
    required String tag,
  }) async {
    if (_isBusy) return;

    switch (action) {
      case _TagAction.rename:
        await _renameTag(tag);
      case _TagAction.merge:
        await _mergeTag(tag);
      case _TagAction.delete:
        await _deleteTag(tag);
    }
  }

  Future<void> _renameTag(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New name',
            prefixIcon: Icon(Icons.sell_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || newName.isEmpty || newName == oldName || !mounted) {
      return;
    }

    await _runTagMutation(
      action: () => ref.read(
        renameTagProvider((oldName: oldName, newName: newName)).future,
      ),
      successMessage: '"$oldName" renamed to "$newName"',
    );
  }

  Future<void> _mergeTag(String sourceName) async {
    final tags = ref.read(tagsWithUsageProvider).asData?.value ?? const [];
    final candidates = tags
        .map((entry) => entry.$1)
        .where((name) => name != sourceName)
        .toList();
    if (candidates.isEmpty || !mounted) return;

    final targetName = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            const ListTile(
              title: Text('Merge Into'),
              subtitle: Text('Choose destination tag'),
            ),
            ...candidates.map(
              (name) => ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Text(name),
                onTap: () => Navigator.pop(context, name),
              ),
            ),
          ],
        ),
      ),
    );

    if (targetName == null || targetName.isEmpty || !mounted) return;

    await _runTagMutation(
      action: () => ref.read(
        mergeTagsProvider((
          sourceName: sourceName,
          targetName: targetName,
        )).future,
      ),
      successMessage: '"$sourceName" merged into "$targetName"',
    );
  }

  Future<void> _deleteTag(String tagName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Delete "$tagName" from all items?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _runTagMutation(
      action: () => ref.read(deleteTagProvider(tagName).future),
      successMessage: '"$tagName" deleted',
    );
  }

  Future<void> _runTagMutation({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() => _isBusy = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag update failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

enum _TagAction { rename, merge, delete }
