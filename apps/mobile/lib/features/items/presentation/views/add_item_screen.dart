import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storage/storage.dart';
import 'package:ui/ui.dart';
import 'package:collection_tracker/core/providers/metadata_providers.dart';
import 'package:collection_tracker/features/collections/presentation/view_models/collections_view_model.dart';
import 'package:metadata_api/metadata_api.dart';
import 'metadata_search_delegate.dart';

import '../view_models/items_view_model.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const AddItemScreen({required this.collectionId, super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _imageStorageService = ImageStorageService();

  bool _isLoading = false;
  bool _isFetchingMetadata = false;
  String? _imagePath;
  String? _coverImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            Center(
              child: ImagePickerWidget(
                imagePath: _imagePath,
                imageUrl: _coverImageUrl,
                onPickFromGallery: () async {
                  final path = await _imageStorageService
                      .pickImageFromGallery();
                  if (path != null && mounted) {
                    setState(() {
                      _imagePath = path;
                      _coverImageUrl = null;
                    });
                  }
                },
                onPickFromCamera: () async {
                  final path = await _imageStorageService.pickImageFromCamera();
                  if (path != null && mounted) {
                    setState(() {
                      _imagePath = path;
                      _coverImageUrl = null;
                    });
                  }
                },
                onRemove: () {
                  setState(() {
                    _imagePath = null;
                    _coverImageUrl = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., The Lord of the Rings',
                prefixIcon: const Icon(Icons.title),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showMetadataSearch(context),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode field
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barcode (optional)',
                hintText: 'ISBN, UPC, etc.',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final barcode = await context.push<String>(
                      '/scanner?collectionId=${widget.collectionId}',
                    );

                    if (barcode != null && mounted) {
                      _barcodeController.text = barcode;
                      _fetchMetadata(barcode);
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.text,
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _fetchMetadata(value.trim());
                }
              },
            ),
            if (_isFetchingMetadata)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Fetching metadata...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add a description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Add button
            FilledButton(
              onPressed: _isLoading ? null : _handleAdd,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMetadataSearch(BuildContext context) async {
    final collectionAsync = ref.read(
      collectionDetailProvider(widget.collectionId),
    );
    final collection = collectionAsync.asData?.value;
    if (collection == null) return;

    final result = await showSearch<MetadataBase?>(
      context: context,
      delegate: MetadataSearchDelegate(
        ref: ref,
        collectionType: collection.type,
      ),
      query: _titleController.text,
    );

    if (result != null && mounted) {
      setState(() {
        _titleController.text = result.title;
        if (_descriptionController.text.isEmpty) {
          _descriptionController.text = result.description ?? '';
        }
        _coverImageUrl = result.thumbnailUrl;
      });
    }
  }

  Future<void> _fetchMetadata(String barcode) async {
    final collectionAsync = ref.read(
      collectionDetailProvider(widget.collectionId),
    );

    final collection = collectionAsync.value;
    if (collection == null) return;

    setState(() {
      _isFetchingMetadata = true;
    });

    try {
      final matcher = await ref.read(smartMetadataMatcherProvider.future);
      final result = await matcher.findBestMatch(
        barcode: barcode,
        primaryType: collection.type,
      );

      result.fold(
        (exception) => null, // Ignore errors for now
        (match) {
          if (match.metadata != null && mounted) {
            final metadata = match.metadata!;
            setState(() {
              if (_titleController.text.isEmpty) {
                _titleController.text = metadata.title;
              }
              if (_descriptionController.text.isEmpty) {
                _descriptionController.text = metadata.description ?? '';
              }
              _coverImageUrl = metadata.thumbnailUrl;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Matched ${match.source} metadata'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Metadata fetch error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMetadata = false;
        });
      }
    }
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(
        createItemProvider(
          collectionId: widget.collectionId,
          title: _titleController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          coverImageUrl: _coverImageUrl,
          coverImagePath: _imagePath,
        ).future,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
