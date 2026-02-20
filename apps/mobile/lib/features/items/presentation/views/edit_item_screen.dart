import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/items_view_model.dart';
import '../widgets/item_tags_editor.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final String itemId;

  const EditItemScreen({required this.itemId, super.key});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;
  Item? _item;
  ItemCondition? _selectedCondition;
  List<String> _tags = const [];
  DateTime? _selectedPurchaseDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _purchaseDateController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailProvider(widget.itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Item')),
            body: const Center(child: Text('Item not found')),
          );
        }

        if (!_isInitialized) {
          _item = item;
          _titleController.text = item.title;
          _barcodeController.text = item.barcode ?? '';
          _descriptionController.text = item.description ?? '';
          _purchasePriceController.text = item.purchasePrice != null
              ? item.purchasePrice!.toStringAsFixed(2)
              : '';
          _currentValueController.text = item.currentValue != null
              ? item.currentValue!.toStringAsFixed(2)
              : '';
          _selectedPurchaseDate = item.purchaseDate;
          _purchaseDateController.text = _selectedPurchaseDate != null
              ? _formatDate(_selectedPurchaseDate!)
              : '';
          _notesController.text = item.notes ?? '';
          _locationController.text = item.location ?? '';
          _quantityController.text = item.quantity.toString();
          _selectedCondition = item.condition;
          _tags = List<String>.from(item.tags);
          _isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Item')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
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
                    prefixIcon: const Icon(Icons.qr_code),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        final barcode = await context.push<String>('/scanner');

                        if (barcode != null && mounted) {
                          setState(() {
                            _barcodeController.text = barcode;
                          });
                        }
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
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
                const SizedBox(height: 16),

                ItemTagsEditor(
                  initialTags: _tags,
                  onChanged: (tags) {
                    _tags = tags;
                  },
                  label: 'Tags (optional)',
                  hintText: 'e.g., Signed, First Edition',
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Price',
                          prefixText: '\$',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePriceInput,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentValueController,
                        decoration: const InputDecoration(
                          labelText: 'Current Value',
                          prefixText: '\$',
                          prefixIcon: Icon(Icons.show_chart),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePriceInput,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
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
                const SizedBox(height: 16),

                // Condition selector
                DropdownButtonFormField<ItemCondition>(
                  initialValue: _selectedCondition,
                  decoration: const InputDecoration(
                    labelText: 'Condition (optional)',
                    prefixIcon: Icon(Icons.star),
                  ),
                  items: ItemCondition.values.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Quantity field
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter quantity';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 1) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g., Shelf A, Box 3',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note),
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
        appBar: AppBar(title: const Text('Edit Item')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Item')),
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
      final updated = _item!.copyWith(
        title: _titleController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        quantity: int.parse(_quantityController.text),
        condition: _selectedCondition,
        tags: _tags,
        purchasePrice: _parsePriceInput(_purchasePriceController.text),
        currentValue: _parsePriceInput(_currentValueController.text),
        purchaseDate: _selectedPurchaseDate,
      );

      await ref.read(updateItemProvider(updated).future);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: $e'),
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

  String? _validatePriceInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = _parsePriceInput(value);
    if (parsed == null) {
      return 'Invalid price';
    }
    if (parsed < 0) {
      return 'Must be positive';
    }
    return null;
  }

  double? _parsePriceInput(String raw) {
    final normalized = raw.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _pickPurchaseDate() async {
    final initialDate = _selectedPurchaseDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
