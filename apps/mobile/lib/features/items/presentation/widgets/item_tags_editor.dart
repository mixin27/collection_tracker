import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ItemTagsEditor extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;
  final String? label;
  final String? hintText;

  const ItemTagsEditor({
    required this.initialTags,
    required this.onChanged,
    this.label,
    this.hintText,
    super.key,
  });

  @override
  State<ItemTagsEditor> createState() => _ItemTagsEditorState();
}

class _ItemTagsEditorState extends State<ItemTagsEditor> {
  final _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void didUpdateWidget(covariant ItemTagsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTags != widget.initialTags) {
      _tags = List<String>.from(widget.initialTags);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final label = widget.label ?? l10n.itemsTagsTitle;
    final hintText = widget.hintText ?? l10n.itemTagsEditorHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppInput(
                controller: _controller,
                hintText: hintText,
                prefixIcon: const Icon(Icons.sell_outlined),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
              tooltip: l10n.itemTagsEditorAddTooltip,
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppAnimatedSwitcher(
          duration: AppMotion.medium,
          child: _tags.isEmpty
              ? Container(
                  key: const ValueKey('empty-tags'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.itemTagsEditorEmptyMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : AnimatedSize(
                  key: const ValueKey('tags'),
                  duration: AppMotion.medium,
                  curve: AppMotion.emphasized,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map(
                          (tag) => InputChip(
                            label: Text(tag),
                            selected: true,
                            selectedColor: theme.colorScheme.secondaryContainer,
                            onDeleted: () => _removeTag(tag),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  void _addTag() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.itemTagsEditorTooLong)),
      );
      return;
    }

    final alreadyExists = _tags.any(
      (tag) => tag.toLowerCase() == normalized.toLowerCase(),
    );
    if (alreadyExists) {
      _controller.clear();
      return;
    }

    setState(() {
      _tags = [..._tags, normalized];
      _controller.clear();
    });
    widget.onChanged(_tags);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((value) => value != tag).toList();
    });
    widget.onChanged(_tags);
  }
}
