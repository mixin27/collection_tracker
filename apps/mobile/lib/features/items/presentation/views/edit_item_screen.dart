import 'package:domain/domain.dart';
import 'package:collection_tracker/core/providers/metadata_preferences_provider.dart';
import 'package:collection_tracker/core/providers/metadata_providers.dart';
import 'package:collection_tracker/features/collections/presentation/view_models/collections_view_model.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:metadata_api/metadata_api.dart';
import 'package:ui/ui.dart';

import '../view_models/items_view_model.dart';
import 'metadata_search_delegate.dart';
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
  bool _isFetchingMetadata = false;
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
    final l10n = context.l10n;
    final itemAsync = ref.watch(itemDetailProvider(widget.itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editItemTitle)),
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.itemDetailNotFoundTitle,
              message: l10n.itemDetailNotFoundMessage,
            ),
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

        final collectionAsync = ref.watch(
          collectionDetailProvider(item.collectionId),
        );
        final collection = collectionAsync.asData?.value;
        final metadataPreferences = ref.watch(metadataPreferencesProvider);
        final metadataService = ref.read(metadataLookupServiceProvider);
        final metadataSearchSupported =
            collection != null &&
            metadataPreferences.isEnabled &&
            metadataService.supportsSearch(collection.type);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.editItemTitle)),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppCard(
                  child: Column(
                    children: [
                      AppInput(
                        controller: _titleController,
                        labelText: l10n.itemFormTitleLabel,
                        prefixIcon: const Icon(Icons.title),
                        suffixIcon: Tooltip(
                          message: metadataSearchSupported
                              ? l10n.metadataSearchSuggestionTitle
                              : l10n.metadataSearchDisabledHint,
                          child: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () =>
                                _showMetadataSearch(context, collection?.type),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.itemFormTitleRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        controller: _barcodeController,
                        labelText: l10n.itemFormBarcodeLabelOptional,
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final barcode = await context.push<String>(
                              '/scanner?collectionId=${item.collectionId}',
                            );

                            if (barcode != null && mounted) {
                              setState(() {
                                _barcodeController.text = barcode;
                              });
                              if (metadataPreferences.canAutoFetchFromBarcode) {
                                _fetchMetadata(
                                  barcode,
                                  collectionType: collection?.type,
                                  showNoMatchFeedback: false,
                                );
                              }
                            }
                          },
                        ),
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (value) {
                          if (value.trim().isEmpty) {
                            return;
                          }
                          _fetchMetadata(
                            value.trim(),
                            collectionType: collection?.type,
                          );
                        },
                      ),
                      if (_isFetchingMetadata)
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.sm),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  l10n.addItemFetchingMetadata,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        controller: _descriptionController,
                        labelText: l10n.itemFormDescriptionLabelOptional,
                        prefixIcon: const Icon(Icons.description),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ItemTagsEditor(
                        initialTags: _tags,
                        onChanged: (tags) {
                          _tags = tags;
                        },
                        label: l10n.itemFormTagsLabelOptional,
                        hintText: l10n.editItemTagsHint,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              controller: _purchasePriceController,
                              labelText: l10n.itemDetailPurchasePriceLabel,
                              prefixText: _currencySymbol(context),
                              prefixIcon: const Icon(Icons.attach_money),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: _validatePriceInput,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppInput(
                              controller: _currentValueController,
                              labelText: l10n.itemDetailCurrentValueLabel,
                              prefixText: _currencySymbol(context),
                              prefixIcon: const Icon(Icons.show_chart),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                          labelText: l10n.itemFormPurchaseDateLabelOptional,
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
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<ItemCondition>(
                        initialValue: _selectedCondition,
                        decoration: InputDecoration(
                          labelText: l10n.itemFormConditionLabelOptional,
                          prefixIcon: const Icon(Icons.star),
                        ),
                        items: ItemCondition.values.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(_conditionLabel(context, condition)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCondition = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        controller: _quantityController,
                        labelText: l10n.itemDetailQuantityLabel,
                        prefixIcon: const Icon(Icons.numbers),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.itemFormQuantityRequired;
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity < 1) {
                            return l10n.itemFormQuantityInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        controller: _locationController,
                        labelText: l10n.itemFormLocationLabelOptional,
                        hintText: l10n.itemFormLocationHint,
                        prefixIcon: const Icon(Icons.location_on),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        controller: _notesController,
                        labelText: l10n.itemFormNotesLabelOptional,
                        prefixIcon: const Icon(Icons.note),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save button
                AppButton(
                  label: l10n.editItemSaveChanges,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _handleSave,
                  expand: true,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editItemTitle)),
        body: LoadingView(message: l10n.editItemLoading),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.editItemTitle)),
        body: ErrorView(message: l10n.editItemError('$error')),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.editItemSuccess)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.editItemUpdateError('$e')),
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

  Future<void> _showMetadataSearch(
    BuildContext context,
    CollectionType? collectionType,
  ) async {
    if (collectionType == null) {
      return;
    }

    final metadataPreferences = ref.read(metadataPreferencesProvider);
    if (!metadataPreferences.isEnabled) {
      _showMetadataMessage(context.l10n.settingsMetadataFeatureDisabledMessage);
      return;
    }

    final metadataService = ref.read(metadataLookupServiceProvider);
    if (!metadataService.supportsSearch(collectionType)) {
      _showMetadataMessage(
        context.l10n.metadataSearchUnavailableForType(
          _collectionTypeLabel(collectionType),
        ),
      );
      return;
    }

    final result = await showSearch<MetadataBase?>(
      context: context,
      delegate: MetadataSearchDelegate(
        ref: ref,
        collectionType: collectionType,
        searchFieldLabelText: context.l10n.metadataSearchFieldLabel(
          _collectionTypeLabel(collectionType),
        ),
      ),
      query: _titleController.text,
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _applyMetadata(
        result,
        fillOnlyEmptyFields: metadataPreferences.fillOnlyEmptyFields,
      );
    });
  }

  Future<void> _fetchMetadata(
    String barcode, {
    required CollectionType? collectionType,
    bool showNoMatchFeedback = true,
  }) async {
    if (_isFetchingMetadata || collectionType == null) {
      return;
    }

    final metadataPreferences = ref.read(metadataPreferencesProvider);
    if (!metadataPreferences.isEnabled) {
      if (showNoMatchFeedback) {
        _showMetadataMessage(
          context.l10n.settingsMetadataFeatureDisabledMessage,
        );
      }
      return;
    }

    final metadataService = ref.read(metadataLookupServiceProvider);
    if (!metadataService.supportsBarcodeLookup(primaryType: collectionType)) {
      if (showNoMatchFeedback) {
        _showMetadataMessage(
          context.l10n.metadataSearchUnavailableForType(
            _collectionTypeLabel(collectionType),
          ),
        );
      }
      return;
    }

    setState(() {
      _isFetchingMetadata = true;
    });

    try {
      final result = await metadataService.findBestBarcodeMatch(
        barcode: barcode,
        primaryType: collectionType,
      );

      if (!mounted) {
        return;
      }

      if (result.metadata != null) {
        setState(() {
          _applyMetadata(
            result.metadata!,
            fillOnlyEmptyFields: metadataPreferences.fillOnlyEmptyFields,
          );
        });

        _showMetadataMessage(
          context.l10n.addItemMatchedMetadata(
            _metadataSourceLabel(result.source),
          ),
        );
      } else if (showNoMatchFeedback) {
        _showMetadataMessage(context.l10n.metadataNoMatchForBarcode);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (showNoMatchFeedback) {
        _showMetadataMessage(context.l10n.metadataNoMatchForBarcode);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMetadata = false;
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
      return context.l10n.itemFormInvalidPrice;
    }
    if (parsed < 0) {
      return context.l10n.itemFormMustBePositive;
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).format(date);
  }

  String _currencySymbol(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.simpleCurrency(locale: locale).currencySymbol;
  }

  String _conditionLabel(BuildContext context, ItemCondition condition) {
    final l10n = context.l10n;
    return switch (condition) {
      ItemCondition.mint => l10n.itemConditionMint,
      ItemCondition.good => l10n.itemConditionGood,
      ItemCondition.fair => l10n.itemConditionFair,
      ItemCondition.poor => l10n.itemConditionPoor,
    };
  }

  void _applyMetadata(
    MetadataBase metadata, {
    required bool fillOnlyEmptyFields,
  }) {
    final title = metadata.title.trim();
    final description = metadata.description?.trim();

    if (fillOnlyEmptyFields) {
      if (_titleController.text.trim().isEmpty && title.isNotEmpty) {
        _titleController.text = title;
      }
      if (_descriptionController.text.trim().isEmpty &&
          description != null &&
          description.isNotEmpty) {
        _descriptionController.text = description;
      }
      return;
    }

    if (title.isNotEmpty) {
      _titleController.text = title;
    }
    if (description != null && description.isNotEmpty) {
      _descriptionController.text = description;
    }
  }

  String _collectionTypeLabel(CollectionType type) {
    final l10n = context.l10n;
    return switch (type) {
      CollectionType.book => l10n.collectionTypeBooks,
      CollectionType.game => l10n.collectionTypeGames,
      CollectionType.movie => l10n.collectionTypeMovies,
      CollectionType.comic => l10n.collectionTypeComics,
      CollectionType.music => l10n.collectionTypeMusic,
      CollectionType.custom => l10n.collectionTypeCustom,
    };
  }

  String _metadataSourceLabel(String source) {
    return switch (source.toLowerCase()) {
      'book' => context.l10n.collectionTypeBooks,
      'game' => context.l10n.collectionTypeGames,
      'movie' => context.l10n.collectionTypeMovies,
      _ => source,
    };
  }

  void _showMetadataMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
