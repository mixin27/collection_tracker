import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/collections_view_model.dart';

class EditCollectionScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const EditCollectionScreen({required this.collectionId, super.key});

  @override
  ConsumerState<EditCollectionScreen> createState() =>
      _EditCollectionScreenState();
}

class _EditCollectionScreenState extends ConsumerState<EditCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CollectionType? _selectedType;
  bool _isSaving = false;
  bool _isInitialized = false;
  Collection? _collection;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionAsync = ref.watch(
      collectionDetailProvider(widget.collectionId),
    );

    return collectionAsync.when(
      data: (collection) {
        if (collection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Collection')),
            body: const Center(child: Text('Collection not found')),
          );
        }

        if (!_isInitialized) {
          _collection = collection;
          _nameController.text = collection.name;
          _descriptionController.text = collection.description ?? '';
          _selectedType = collection.type;
          _isInitialized = true;
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Collection')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Collection Name',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a collection name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type selector
                Text('Collection Type', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CollectionType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getIconForType(type), size: 18),
                          const SizedBox(width: 4),
                          Text(_getNameForType(type)),
                        ],
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = type;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Save button
                FilledButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit Collection')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Collection')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = _collection!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await ref
          .read(collectionsViewModelProvider.notifier)
          .updateCollection(updated);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating collection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  IconData _getIconForType(CollectionType type) {
    switch (type) {
      case CollectionType.book:
        return Icons.book;
      case CollectionType.game:
        return Icons.videogame_asset;
      case CollectionType.movie:
        return Icons.movie;
      case CollectionType.comic:
        return Icons.menu_book;
      case CollectionType.music:
        return Icons.album;
      case CollectionType.custom:
        return Icons.category;
    }
  }

  String _getNameForType(CollectionType type) {
    switch (type) {
      case CollectionType.book:
        return 'Books';
      case CollectionType.game:
        return 'Games';
      case CollectionType.movie:
        return 'Movies';
      case CollectionType.comic:
        return 'Comics';
      case CollectionType.music:
        return 'Music';
      case CollectionType.custom:
        return 'Custom';
    }
  }
}
