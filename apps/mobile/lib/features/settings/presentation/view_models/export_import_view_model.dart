import 'dart:convert';

import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:database/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'export_import_view_model.g.dart';

@riverpod
class ExportImportViewModel extends _$ExportImportViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed.
  }

  Future<String> exportAllDataToJson() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;
    final stopwatch = Stopwatch()..start();
    final db = ref.read(appDatabaseProvider);
    final exportService = ExportImportService();
    var collectionCount = 0;
    var itemCount = 0;

    final result = await AsyncValue.guard(
      () => performanceService.traceAsync(
        'settings_export_all_data_json',
        () async {
          final collections = await db.select(db.collections).get();
          final items = await db.select(db.items).get();
          final tags = await db.select(db.tags).get();
          final itemTags = await db.select(db.itemTags).get();
          final priceHistory = await db.select(db.itemPriceHistory).get();
          final loans = await db.select(db.itemLoans).get();

          collectionCount = collections.length;
          itemCount = items.length;

          final exportData = <String, dynamic>{
            'version': '2.0.0',
            'schema': 'collection_tracker_backup',
            'exportDate': DateTime.now().toIso8601String(),
            'collections': collections
                .map(
                  (collection) => <String, dynamic>{
                    'id': collection.id,
                    'name': collection.name,
                    'type': collection.type,
                    'description': collection.description,
                    'coverImagePath': collection.coverImagePath,
                    'itemCount': collection.itemCount,
                    'createdAt': collection.createdAt.toIso8601String(),
                    'updatedAt': collection.updatedAt.toIso8601String(),
                  },
                )
                .toList(growable: false),
            'items': items
                .map(
                  (item) => <String, dynamic>{
                    'id': item.id,
                    'collectionId': item.collectionId,
                    'title': item.title,
                    'barcode': item.barcode,
                    'coverImageUrl': item.coverImageUrl,
                    'coverImagePath': item.coverImagePath,
                    'description': item.description,
                    'notes': item.notes,
                    'metadata': item.metadata,
                    'condition': item.condition,
                    'purchasePrice': item.purchasePrice,
                    'purchaseDate': item.purchaseDate?.toIso8601String(),
                    'currentValue': item.currentValue,
                    'location': item.location,
                    'isFavorite': item.isFavorite,
                    'isWishlist': item.isWishlist,
                    'sortOrder': item.sortOrder,
                    'quantity': item.quantity,
                    'createdAt': item.createdAt.toIso8601String(),
                    'updatedAt': item.updatedAt.toIso8601String(),
                  },
                )
                .toList(growable: false),
            'tags': tags
                .map(
                  (tag) => <String, dynamic>{
                    'id': tag.id,
                    'name': tag.name,
                    'color': tag.color,
                    'createdAt': tag.createdAt.toIso8601String(),
                    'updatedAt': tag.updatedAt.toIso8601String(),
                  },
                )
                .toList(growable: false),
            'itemTags': itemTags
                .map(
                  (relation) => <String, dynamic>{
                    'itemId': relation.itemId,
                    'tagId': relation.tagId,
                  },
                )
                .toList(growable: false),
            'priceHistory': priceHistory
                .map(
                  (history) => <String, dynamic>{
                    'id': history.id,
                    'itemId': history.itemId,
                    'value': history.value,
                    'recordedAt': history.recordedAt.toIso8601String(),
                    'source': history.source,
                  },
                )
                .toList(growable: false),
            'loans': loans
                .map(
                  (loan) => <String, dynamic>{
                    'id': loan.id,
                    'itemId': loan.itemId,
                    'borrowerName': loan.borrowerName,
                    'borrowerContact': loan.borrowerContact,
                    'notes': loan.notes,
                    'loanedAt': loan.loanedAt.toIso8601String(),
                    'dueAt': loan.dueAt?.toIso8601String(),
                    'returnedAt': loan.returnedAt?.toIso8601String(),
                    'createdAt': loan.createdAt.toIso8601String(),
                    'updatedAt': loan.updatedAt.toIso8601String(),
                  },
                )
                .toList(growable: false),
          };

          return exportService.exportToJson(exportData);
        },
      ),
    );

    _setStateSafely(result);
    stopwatch.stop();

    if (result.hasError) {
      final error = result.error;
      if (error is UserCancelledStorageOperationException) {
        throw error;
      }
      await OperationalTelemetry.trackDataTransfer(
        operation: 'export_json',
        success: false,
        durationMs: stopwatch.elapsedMilliseconds,
        collectionCount: collectionCount,
        itemCount: itemCount,
        error: error,
        stackTrace: result.stackTrace,
      );
      throw error!;
    }

    await OperationalTelemetry.trackDataTransfer(
      operation: 'export_json',
      success: true,
      durationMs: stopwatch.elapsedMilliseconds,
      collectionCount: collectionCount,
      itemCount: itemCount,
    );

    return result.value!;
  }

  Future<String> exportItemsToCsv() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;
    final stopwatch = Stopwatch()..start();
    final db = ref.read(appDatabaseProvider);
    final exportService = ExportImportService();
    var collectionCount = 0;
    var itemCount = 0;

    final result = await AsyncValue.guard(
      () =>
          performanceService.traceAsync('settings_export_items_csv', () async {
            final collections = await db.select(db.collections).get();
            final items = await db.select(db.items).get();
            final tags = await db.select(db.tags).get();
            final itemTags = await db.select(db.itemTags).get();

            collectionCount = collections.length;
            itemCount = items.length;

            final collectionById = <String, CollectionData>{
              for (final collection in collections) collection.id: collection,
            };
            final tagNameById = <String, String>{
              for (final tag in tags) tag.id: tag.name,
            };
            final tagsByItemId = <String, List<String>>{};
            for (final relation in itemTags) {
              final tagName = tagNameById[relation.tagId];
              if (tagName == null) {
                continue;
              }
              tagsByItemId
                  .putIfAbsent(relation.itemId, () => <String>[])
                  .add(tagName);
            }

            final rows = items
                .map((item) {
                  final collectionName =
                      collectionById[item.collectionId]?.name ??
                      item.collectionId;
                  final itemTags = (tagsByItemId[item.id] ?? const <String>[])
                      .join(', ');

                  return <String, dynamic>{
                    'Collection': collectionName,
                    'Title': item.title,
                    'Quantity': item.quantity.toString(),
                    'Current Value': item.currentValue?.toString() ?? '',
                    'Purchase Price': item.purchasePrice?.toString() ?? '',
                    'Barcode': item.barcode ?? '',
                    'Tags': itemTags,
                    'Description': item.description ?? '',
                    'Condition': item.condition ?? '',
                    'Location': item.location ?? '',
                    'Notes': item.notes ?? '',
                    'Favorite': item.isFavorite ? 'Yes' : 'No',
                    'Wishlist': item.isWishlist ? 'Yes' : 'No',
                    'Created': item.createdAt.toIso8601String(),
                    'Updated': item.updatedAt.toIso8601String(),
                  };
                })
                .toList(growable: false);

            return exportService.exportToCsv(rows);
          }),
    );

    _setStateSafely(result);
    stopwatch.stop();

    if (result.hasError) {
      final error = result.error;
      if (error is UserCancelledStorageOperationException) {
        throw error;
      }
      await OperationalTelemetry.trackDataTransfer(
        operation: 'export_csv',
        success: false,
        durationMs: stopwatch.elapsedMilliseconds,
        collectionCount: collectionCount,
        itemCount: itemCount,
        error: error,
        stackTrace: result.stackTrace,
      );
      throw error!;
    }

    await OperationalTelemetry.trackDataTransfer(
      operation: 'export_csv',
      success: true,
      durationMs: stopwatch.elapsedMilliseconds,
      collectionCount: collectionCount,
      itemCount: itemCount,
    );

    return result.value!;
  }

  Future<void> importFromJson() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;
    final stopwatch = Stopwatch()..start();
    final db = ref.read(appDatabaseProvider);
    final exportService = ExportImportService();
    var collectionCount = 0;
    var itemCount = 0;

    final result = await AsyncValue.guard(
      () =>
          performanceService.traceAsync('settings_import_data_json', () async {
            final data = await exportService.importFromJson();

            final collections = _readMapList(data, 'collections');
            final items = _readMapList(data, 'items');
            final tags = _readMapList(data, 'tags');
            final itemTags = _readMapList(data, 'itemTags');
            final priceHistory = _readMapList(data, 'priceHistory');
            final loans = _readMapList(data, 'loans');

            if (collections.isEmpty && items.isEmpty) {
              throw const FormatException(
                'Invalid backup format: collections/items are missing.',
              );
            }

            collectionCount = collections.length;
            itemCount = items.length;

            await db.transaction(() async {
              await _importCollections(db, collections);
              await _importItems(db, items);
              final tagIdRemap = await _importTags(db, tags);
              await _importItemTags(db, itemTags, tagIdRemap);
              await _importPriceHistory(db, priceHistory);
              await _importLoans(db, loans);
              await _recalculateCollectionItemCounts(db);
            });
          }),
    );

    _setStateSafely(result);
    stopwatch.stop();

    if (result.hasError) {
      final error = result.error;
      if (error is UserCancelledStorageOperationException) {
        throw error;
      }
      await OperationalTelemetry.trackDataTransfer(
        operation: 'import_json',
        success: false,
        durationMs: stopwatch.elapsedMilliseconds,
        collectionCount: collectionCount,
        itemCount: itemCount,
        error: error,
        stackTrace: result.stackTrace,
      );
      throw error!;
    }

    await OperationalTelemetry.trackDataTransfer(
      operation: 'import_json',
      success: true,
      durationMs: stopwatch.elapsedMilliseconds,
      collectionCount: collectionCount,
      itemCount: itemCount,
    );
  }

  Future<void> _importCollections(
    AppDatabase db,
    List<Map<String, dynamic>> collections,
  ) async {
    for (final raw in collections) {
      final id = _requiredString(raw, 'id');
      final name = _requiredString(raw, 'name');
      final type = _nullableString(raw['type']) ?? 'custom';
      final now = DateTime.now();

      await db
          .into(db.collections)
          .insert(
            CollectionsCompanion(
              id: Value(id),
              name: Value(name),
              type: Value(type),
              description: Value(_nullableString(raw['description'])),
              coverImagePath: Value(_nullableString(raw['coverImagePath'])),
              itemCount: Value(_nullableInt(raw['itemCount']) ?? 0),
              createdAt: Value(_dateTimeOr(raw['createdAt'], now)),
              updatedAt: Value(_dateTimeOr(raw['updatedAt'], now)),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _importItems(
    AppDatabase db,
    List<Map<String, dynamic>> items,
  ) async {
    final collections = await db.select(db.collections).get();
    final validCollectionIds = collections.map((e) => e.id).toSet();

    for (final raw in items) {
      final collectionId = _requiredString(raw, 'collectionId');
      if (!validCollectionIds.contains(collectionId)) {
        continue;
      }

      final id = _requiredString(raw, 'id');
      final title = _requiredString(raw, 'title');
      final now = DateTime.now();

      await db
          .into(db.items)
          .insert(
            ItemsCompanion(
              id: Value(id),
              collectionId: Value(collectionId),
              title: Value(title),
              barcode: Value(_nullableString(raw['barcode'])),
              coverImageUrl: Value(_nullableString(raw['coverImageUrl'])),
              coverImagePath: Value(_nullableString(raw['coverImagePath'])),
              description: Value(_nullableString(raw['description'])),
              notes: Value(_nullableString(raw['notes'])),
              metadata: Value(_stringOrJson(raw['metadata'])),
              condition: Value(_nullableString(raw['condition'])),
              purchasePrice: Value(_nullableDouble(raw['purchasePrice'])),
              purchaseDate: Value(_nullableDateTime(raw['purchaseDate'])),
              currentValue: Value(_nullableDouble(raw['currentValue'])),
              location: Value(_nullableString(raw['location'])),
              isFavorite: Value(_boolOr(raw['isFavorite'], false)),
              isWishlist: Value(_boolOr(raw['isWishlist'], false)),
              sortOrder: Value(_nullableInt(raw['sortOrder']) ?? 0),
              quantity: Value(_nullableInt(raw['quantity']) ?? 1),
              createdAt: Value(_dateTimeOr(raw['createdAt'], now)),
              updatedAt: Value(_dateTimeOr(raw['updatedAt'], now)),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<Map<String, String>> _importTags(
    AppDatabase db,
    List<Map<String, dynamic>> tags,
  ) async {
    final existingTags = await db.select(db.tags).get();
    final knownTagIds = <String>{for (final tag in existingTags) tag.id};
    final knownTagNameToId = <String, String>{
      for (final tag in existingTags) tag.name.trim().toLowerCase(): tag.id,
    };
    final importedToResolvedTagId = <String, String>{};

    for (final raw in tags) {
      final importedId = _requiredString(raw, 'id');
      final name = _requiredString(raw, 'name');
      final normalizedName = name.trim().toLowerCase();
      final now = DateTime.now();

      final targetId = knownTagIds.contains(importedId)
          ? importedId
          : (knownTagNameToId[normalizedName] ?? importedId);

      importedToResolvedTagId[importedId] = targetId;

      await db
          .into(db.tags)
          .insert(
            TagsCompanion(
              id: Value(targetId),
              name: Value(name),
              color: Value(_nullableString(raw['color'])),
              createdAt: Value(_dateTimeOr(raw['createdAt'], now)),
              updatedAt: Value(_dateTimeOr(raw['updatedAt'], now)),
            ),
            mode: InsertMode.insertOrReplace,
          );

      knownTagIds.add(targetId);
      knownTagNameToId[normalizedName] = targetId;
    }

    return importedToResolvedTagId;
  }

  Future<void> _importItemTags(
    AppDatabase db,
    List<Map<String, dynamic>> itemTags,
    Map<String, String> tagIdRemap,
  ) async {
    final itemIds = (await db.select(db.items).get()).map((e) => e.id).toSet();
    final tagIds = (await db.select(db.tags).get()).map((e) => e.id).toSet();

    for (final raw in itemTags) {
      final itemId = _requiredString(raw, 'itemId');
      final importedTagId = _requiredString(raw, 'tagId');
      final resolvedTagId = tagIdRemap[importedTagId] ?? importedTagId;

      if (!itemIds.contains(itemId) || !tagIds.contains(resolvedTagId)) {
        continue;
      }

      await db
          .into(db.itemTags)
          .insert(
            ItemTagsCompanion.insert(itemId: itemId, tagId: resolvedTagId),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _importPriceHistory(
    AppDatabase db,
    List<Map<String, dynamic>> priceHistory,
  ) async {
    final itemIds = (await db.select(db.items).get()).map((e) => e.id).toSet();

    for (final raw in priceHistory) {
      final id = _requiredString(raw, 'id');
      final itemId = _requiredString(raw, 'itemId');
      if (!itemIds.contains(itemId)) {
        continue;
      }

      final value = _nullableDouble(raw['value']);
      if (value == null) {
        continue;
      }

      final now = DateTime.now();
      await db
          .into(db.itemPriceHistory)
          .insert(
            ItemPriceHistoryCompanion(
              id: Value(id),
              itemId: Value(itemId),
              value: Value(value),
              recordedAt: Value(_dateTimeOr(raw['recordedAt'], now)),
              source: Value(_nullableString(raw['source']) ?? 'manual'),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _importLoans(
    AppDatabase db,
    List<Map<String, dynamic>> loans,
  ) async {
    final itemIds = (await db.select(db.items).get()).map((e) => e.id).toSet();

    for (final raw in loans) {
      final id = _requiredString(raw, 'id');
      final itemId = _requiredString(raw, 'itemId');
      if (!itemIds.contains(itemId)) {
        continue;
      }

      final borrowerName = _requiredString(raw, 'borrowerName');
      final now = DateTime.now();

      await db
          .into(db.itemLoans)
          .insert(
            ItemLoansCompanion(
              id: Value(id),
              itemId: Value(itemId),
              borrowerName: Value(borrowerName),
              borrowerContact: Value(_nullableString(raw['borrowerContact'])),
              notes: Value(_nullableString(raw['notes'])),
              loanedAt: Value(_dateTimeOr(raw['loanedAt'], now)),
              dueAt: Value(_nullableDateTime(raw['dueAt'])),
              returnedAt: Value(_nullableDateTime(raw['returnedAt'])),
              createdAt: Value(_dateTimeOr(raw['createdAt'], now)),
              updatedAt: Value(_dateTimeOr(raw['updatedAt'], now)),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _recalculateCollectionItemCounts(AppDatabase db) async {
    final allCollections = await db.select(db.collections).get();
    final now = DateTime.now();

    for (final collection in allCollections) {
      final row = await db
          .customSelect(
            '''
            SELECT COUNT(*) AS count
            FROM items
            WHERE collection_id = ?
            ''',
            variables: [Variable<String>(collection.id)],
            readsFrom: {db.items},
          )
          .getSingle();
      final count = row.read<int>('count');

      await (db.update(
        db.collections,
      )..where((tbl) => tbl.id.equals(collection.id))).write(
        CollectionsCompanion(itemCount: Value(count), updatedAt: Value(now)),
      );
    }
  }

  List<Map<String, dynamic>> _readMapList(
    Map<String, dynamic> source,
    String key,
  ) {
    final value = source[key];
    if (value == null) {
      return const <Map<String, dynamic>>[];
    }
    if (value is! List) {
      throw FormatException('Invalid backup format: "$key" must be a list.');
    }

    return value
        .map<Map<String, dynamic>>((entry) {
          if (entry is Map<String, dynamic>) {
            return entry;
          }
          if (entry is Map) {
            return entry.map(
              (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
            );
          }
          throw FormatException(
            'Invalid backup format: "$key" contains a non-object element.',
          );
        })
        .toList(growable: false);
  }

  String _requiredString(Map<String, dynamic> source, String key) {
    final value = _nullableString(source[key]);
    if (value == null) {
      throw FormatException('Invalid backup data: "$key" is required.');
    }
    return value;
  }

  String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _stringOrJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }
    return jsonEncode(value);
  }

  int? _nullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  double? _nullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  bool _boolOr(dynamic value, bool fallback) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  DateTime _dateTimeOr(dynamic value, DateTime fallback) {
    return _nullableDateTime(value) ?? fallback;
  }

  DateTime? _nullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  void _setStateSafely<T>(AsyncValue<T> value) {
    try {
      state = value.whenData((_) {});
    } catch (_) {
      // Ignore if provider was disposed while async work was running.
    }
  }
}
