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
  bool _selectionMode = false;
  final Set<String> _selectedTags = <String>{};

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
      appBar: AppBar(
        title: Text(
          _selectionMode ? '${_selectedTags.length} selected' : 'Manage Tags',
        ),
        actions: _selectionMode
            ? [
                IconButton(
                  tooltip: 'Merge selected',
                  onPressed: _selectedTags.length >= 2 && !_isBusy
                      ? _mergeSelectedTags
                      : null,
                  icon: const Icon(Icons.merge_type),
                ),
                IconButton(
                  tooltip: 'Delete selected',
                  onPressed: _selectedTags.isNotEmpty && !_isBusy
                      ? _deleteSelectedTags
                      : null,
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: 'Cancel selection',
                  onPressed: _isBusy ? null : _clearSelectionMode,
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                IconButton(
                  tooltip: 'Select tags',
                  onPressed: _isBusy
                      ? null
                      : () => setState(() => _selectionMode = true),
                  icon: const Icon(Icons.checklist),
                ),
              ],
      ),
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

                  return Column(
                    children: [
                      if (_selectionMode)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _isBusy
                                    ? null
                                    : () => _selectAllFiltered(
                                        filtered.map((entry) => entry.$1),
                                      ),
                                icon: const Icon(Icons.select_all),
                                label: const Text('Select all filtered'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _isBusy || _selectedTags.isEmpty
                                    ? null
                                    : _clearSelectionMode,
                                icon: const Icon(Icons.deselect),
                                label: const Text('Clear selection'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          key: const ValueKey('tags-list'),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tag = filtered[index].$1;
                            final usage = filtered[index].$2;
                            final isSelected = _selectedTags.contains(tag);

                            return Card(
                                  child: ListTile(
                                    onTap: _selectionMode
                                        ? () => _toggleSelection(tag)
                                        : null,
                                    leading: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      child: _selectionMode
                                          ? Checkbox(
                                              key: ValueKey('checkbox-$tag'),
                                              value: isSelected,
                                              onChanged: _isBusy
                                                  ? null
                                                  : (_) =>
                                                        _toggleSelection(tag),
                                            )
                                          : CircleAvatar(
                                              key: ValueKey('avatar-$tag'),
                                              backgroundColor: theme
                                                  .colorScheme
                                                  .secondaryContainer,
                                              child: const Icon(
                                                Icons.sell_outlined,
                                              ),
                                            ),
                                    ),
                                    title: Text(tag),
                                    subtitle: Text(
                                      usage == 1
                                          ? 'Used in 1 item'
                                          : 'Used in $usage items',
                                    ),
                                    trailing: _selectionMode
                                        ? null
                                        : PopupMenuButton<_TagAction>(
                                            onSelected: (action) =>
                                                _handleAction(
                                                  action: action,
                                                  tag: tag,
                                                ),
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                value: _TagAction.rename,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  leading: Icon(
                                                    Icons
                                                        .drive_file_rename_outline,
                                                  ),
                                                  title: Text('Rename'),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: _TagAction.merge,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  leading: Icon(
                                                    Icons.merge_type,
                                                  ),
                                                  title: Text('Merge Into...'),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: _TagAction.delete,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  leading: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  title: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
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
                        ),
                      ),
                    ],
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
    var draftName = oldName;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Tag'),
        content: TextFormField(
          initialValue: oldName,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New name',
            prefixIcon: Icon(Icons.sell_outlined),
          ),
          onChanged: (value) {
            draftName = value.trim();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

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

  void _toggleSelection(String tag) {
    if (_isBusy) return;
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      if (_selectedTags.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _clearSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedTags.clear();
    });
  }

  void _selectAllFiltered(Iterable<String> filteredTags) {
    if (_isBusy) return;
    setState(() {
      _selectedTags.addAll(filteredTags);
      _selectionMode = _selectedTags.isNotEmpty;
    });
  }

  Future<void> _mergeSelectedTags() async {
    final selected = _selectedTags.toList()..sort();
    if (selected.length < 2 || !mounted) return;

    String destination = selected.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Merge Selected Tags'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose destination tag:'),
              const SizedBox(height: 12),
              ...selected.map(
                (tag) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    destination == tag
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(tag),
                  onTap: () => setDialogState(() => destination = tag),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Merge'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final sources = selected.where((tag) => tag != destination).toList();
    await _runTagMutation(
      action: () async {
        for (final source in sources) {
          await ref.read(
            mergeTagsProvider((
              sourceName: source,
              targetName: destination,
            )).future,
          );
        }
      },
      successMessage: 'Merged ${sources.length} tags into "$destination"',
    );
    if (mounted) {
      _clearSelectionMode();
    }
  }

  Future<void> _deleteSelectedTags() async {
    final selected = _selectedTags.toList()..sort();
    if (selected.isEmpty || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Tags'),
        content: Text(
          'Delete ${selected.length} selected tags from all items?\n\nThis cannot be undone.',
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
      action: () async {
        for (final tag in selected) {
          await ref.read(deleteTagProvider(tag).future);
        }
      },
      successMessage: 'Deleted ${selected.length} tags',
    );
    if (mounted) {
      _clearSelectionMode();
    }
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
