import 'dart:developer';

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
import '../widgets/item_tags_editor.dart';

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
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _purchaseDateController = TextEditingController();

  final _imageStorageService = ImageStorageService();

  bool _isLoading = false;
  bool _isFetchingMetadata = false;
  String? _imagePath;
  String? _coverImageUrl;
  List<String> _tags = const [];
  DateTime? _selectedPurchaseDate;

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch collection details so they are available for search/scan actions
    ref.watch(collectionDetailProvider(widget.collectionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Image picker
            AppCard(
              child: Center(
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
                    final path = await _imageStorageService
                        .pickImageFromCamera();
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
            ),
            const SizedBox(height: AppSpacing.lg),

            AppCard(
              child: Column(
                children: [
                  AppInput(
                    controller: _titleController,
                    labelText: 'Title',
                    hintText: 'e.g., The Lord of the Rings',
                    prefixIcon: const Icon(Icons.title),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _showMetadataSearch(context),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    controller: _barcodeController,
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
                    keyboardType: TextInputType.text,
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _fetchMetadata(value.trim());
                      }
                    },
                  ),
                  if (_isFetchingMetadata)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    controller: _descriptionController,
                    labelText: 'Description (optional)',
                    hintText: 'Add a description',
                    prefixIcon: const Icon(Icons.description),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ItemTagsEditor(
                    initialTags: _tags,
                    onChanged: (tags) {
                      _tags = tags;
                    },
                    label: 'Tags (optional)',
                    hintText: 'e.g., Rare, Completed Set',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: _purchasePriceController,
                          labelText: 'Purchase Price',
                          prefixText: '\$',
                          prefixIcon: const Icon(Icons.attach_money),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validatePriceInput,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppInput(
                          controller: _currentValueController,
                          labelText: 'Current Value',
                          prefixText: '\$',
                          prefixIcon: const Icon(Icons.show_chart),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validatePriceInput,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    controller: _purchaseDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Purchase Date (optional)',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: _selectedPurchaseDate == null
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedPurchaseDate = null;
                                  _purchaseDateController.clear();
                                });
                              },
                            ),
                    ),
                    onTap: _pickPurchaseDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Add button
            AppButton(
              label: 'Add Item',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleAdd,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMetadataSearch(BuildContext context) async {
    log('show metadata search');
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
          tags: _tags,
          purchasePrice: _parsePriceInput(_purchasePriceController.text),
          currentValue: _parsePriceInput(_currentValueController.text),
          purchaseDate: _selectedPurchaseDate,
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

  String? _validatePriceInput(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = _parsePriceInput(value);
    if (parsed == null) return 'Invalid price';
    if (parsed < 0) return 'Must be positive';
    return null;
  }

  double? _parsePriceInput(String raw) {
    final normalized = raw.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedPurchaseDate = picked;
      _purchaseDateController.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
