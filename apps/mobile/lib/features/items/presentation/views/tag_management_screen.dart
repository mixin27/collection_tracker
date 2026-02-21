import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';
import 'package:collection_tracker/l10n/l10n.dart';

import '../view_models/tag_management_view_model.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() =>
      _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  static const int _pageSize = 50;
  String _query = '';
  bool _isBusy = false;
  bool _selectionMode = false;
  final Set<String> _selectedTags = <String>{};
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tagsAsync = ref.watch(tagsWithUsageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? l10n.tagManagementSelectedCount(_selectedTags.length)
              : l10n.tagManagementTitle,
        ),
        actions: _selectionMode
            ? [
                IconButton(
                  tooltip: l10n.tagManagementCancelSelectionTooltip,
                  onPressed: _isBusy ? null : _clearSelectionMode,
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                IconButton(
                  tooltip: l10n.tagManagementSelectTagsTooltip,
                  onPressed: _isBusy
                      ? null
                      : () => setState(() => _selectionMode = true),
                  icon: const Icon(Icons.checklist),
                ),
              ],
      ),
      bottomNavigationBar: _selectionMode
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: l10n.actionReset,
                          icon: const Icon(Icons.deselect, size: 18),
                          variant: AppButtonVariant.secondary,
                          onPressed: _selectedTags.isEmpty || _isBusy
                              ? null
                              : _clearSelectionMode,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: l10n.tagManagementMergeAction,
                          icon: const Icon(Icons.merge_type, size: 18),
                          onPressed: _selectedTags.length < 2 || _isBusy
                              ? null
                              : _mergeSelectedTags,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: l10n.actionDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          variant: AppButtonVariant.danger,
                          onPressed: _selectedTags.isEmpty || _isBusy
                              ? null
                              : _deleteSelectedTags,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppInput(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _query = value.trim();
                _visibleCount = _pageSize;
              }),
              hintText: l10n.tagManagementSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: AppAnimatedSwitcher(
              duration: AppMotion.medium,
              child: tagsAsync.when(
                data: (tags) {
                  final filtered = tags.where((entry) {
                    if (_query.isEmpty) return true;
                    return entry.$1.toLowerCase().contains(
                      _query.toLowerCase(),
                    );
                  }).toList();
                  final visibleCount = _visibleCount.clamp(0, filtered.length);
                  final visible = filtered.take(visibleCount).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      key: const ValueKey('empty-tags'),
                      child: Text(
                        _query.isEmpty
                            ? l10n.tagManagementEmptyTitle
                            : l10n.tagManagementNoMatch(_query),
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (_selectionMode)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.xs,
                          ),
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              AppButton(
                                label: l10n.tagManagementSelectVisible,
                                icon: const Icon(Icons.select_all, size: 18),
                                variant: AppButtonVariant.secondary,
                                onPressed: _isBusy
                                    ? null
                                    : () => _selectAllFiltered(
                                        visible.map((entry) => entry.$1),
                                      ),
                              ),
                              AppButton(
                                label: l10n.tagManagementSelectAllMatches,
                                icon: const Icon(Icons.done_all, size: 18),
                                variant: AppButtonVariant.secondary,
                                onPressed: _isBusy
                                    ? null
                                    : () => _selectAllFiltered(
                                        filtered.map((entry) => entry.$1),
                                      ),
                              ),
                              AppButton(
                                label: l10n.tagManagementClearSelection,
                                icon: const Icon(Icons.deselect, size: 18),
                                variant: AppButtonVariant.secondary,
                                onPressed: _isBusy || _selectedTags.isEmpty
                                    ? null
                                    : _clearSelectionMode,
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          key: const ValueKey('tags-list'),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.xl,
                          ),
                          itemCount:
                              visible.length +
                              (visible.length < filtered.length ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            if (index == visible.length) {
                              final remaining =
                                  filtered.length - visible.length;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.tagManagementScrollMore(remaining),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final tag = visible[index].$1;
                            final usage = visible[index].$2;
                            final isSelected = _selectedTags.contains(tag);

                            return AppReveal(
                              delay: AppMotion.stagger * index,
                              child: AppCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  onLongPress: _isBusy
                                      ? null
                                      : () {
                                          _toggleSelection(tag);
                                          setState(() => _selectionMode = true);
                                        },
                                  onTap: _selectionMode
                                      ? () => _toggleSelection(tag)
                                      : () => context.pushNamed(
                                          'tag-items',
                                          queryParameters: {'tag': tag},
                                        ),
                                  leading: AnimatedSwitcher(
                                    duration: AppMotion.fast,
                                    child: _selectionMode
                                        ? Checkbox(
                                            key: ValueKey('checkbox-$tag'),
                                            value: isSelected,
                                            onChanged: _isBusy
                                                ? null
                                                : (_) => _toggleSelection(tag),
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
                                        ? l10n.tagManagementUsedInOne
                                        : l10n.tagManagementUsedInMany(usage),
                                  ),
                                  trailing: _selectionMode
                                      ? null
                                      : PopupMenuButton<_TagAction>(
                                          onSelected: (action) => _handleAction(
                                            action: action,
                                            tag: tag,
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: _TagAction.rename,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(
                                                  Icons
                                                      .drive_file_rename_outline,
                                                ),
                                                title: Text(
                                                  l10n.tagManagementRenameAction,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: _TagAction.merge,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(Icons.merge_type),
                                                title: Text(
                                                  l10n.tagManagementMergeIntoAction,
                                                ),
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
                                                  l10n.actionDelete,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
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
                    child: Text(l10n.tagManagementLoadError('$error')),
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
    final newName = await showAppDialog<String>(
      context: context,
      title: Text(context.l10n.tagManagementRenameTitle),
      content: AppInput(
        initialValue: oldName,
        autofocus: true,
        labelText: context.l10n.tagManagementNewNameLabel,
        prefixIcon: const Icon(Icons.sell_outlined),
        onChanged: (value) {
          draftName = value.trim();
        },
      ),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context),
        ),
        AppButton(
          label: context.l10n.tagManagementRenameAction,
          onPressed: () => closeAppDialog(context, draftName),
        ),
      ],
    );

    if (newName == null || newName.isEmpty || newName == oldName || !mounted) {
      return;
    }

    await _runTagMutation(
      action: () => ref.read(
        renameTagProvider((oldName: oldName, newName: newName)).future,
      ),
      successMessage: context.l10n.tagManagementRenameSuccess(oldName, newName),
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 120) return;
    if (!mounted || _isBusy) return;

    final tags = ref.read(tagsWithUsageProvider).asData?.value ?? const [];
    final filteredLength = tags.where((entry) {
      if (_query.isEmpty) return true;
      return entry.$1.toLowerCase().contains(_query.toLowerCase());
    }).length;

    if (_visibleCount >= filteredLength) return;
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, filteredLength);
    });
  }

  Future<void> _mergeSelectedTags() async {
    final selected = _selectedTags.toList()..sort();
    if (selected.length < 2 || !mounted) return;

    String destination = selected.first;
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(context.l10n.tagManagementMergeSelectedTitle),
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.tagManagementChooseDestination),
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
      ),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: context.l10n.tagManagementMergeAction,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
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
      successMessage: context.l10n.tagManagementMergeSelectedSuccess(
        sources.length,
        destination,
      ),
    );
    if (mounted) {
      _clearSelectionMode();
    }
  }

  Future<void> _deleteSelectedTags() async {
    final selected = _selectedTags.toList()..sort();
    if (selected.isEmpty || !mounted) return;

    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(context.l10n.tagManagementDeleteSelectedTitle),
      content: Text(
        context.l10n.tagManagementDeleteSelectedMessage(selected.length),
      ),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: context.l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !mounted) return;

    await _runTagMutation(
      action: () async {
        for (final tag in selected) {
          await ref.read(deleteTagProvider(tag).future);
        }
      },
      successMessage: context.l10n.tagManagementDeleteSelectedSuccess(
        selected.length,
      ),
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

    final targetName = await showAppSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            ListTile(
              title: Text(context.l10n.tagManagementMergeIntoTitle),
              subtitle: Text(context.l10n.tagManagementChooseDestination),
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
      successMessage: context.l10n.tagManagementMergeSuccess(
        sourceName,
        targetName,
      ),
    );
  }

  Future<void> _deleteTag(String tagName) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(context.l10n.tagManagementDeleteTitle),
      content: Text(context.l10n.tagManagementDeleteMessage(tagName)),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: context.l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !mounted) return;

    await _runTagMutation(
      action: () => ref.read(deleteTagProvider(tagName).future),
      successMessage: context.l10n.tagManagementDeleteSuccess(tagName),
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
            content: Text(context.l10n.tagManagementMutationError('$e')),
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
