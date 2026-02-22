import 'dart:convert';

import 'package:database/database.dart';
import 'package:sync_api/sync_api.dart';

class SyncServerChangeApplyResult {
  const SyncServerChangeApplyResult({
    required this.appliedCollections,
    required this.appliedItems,
    required this.appliedTags,
    required this.skippedCollections,
    required this.skippedItems,
    required this.skippedTags,
  });

  final int appliedCollections;
  final int appliedItems;
  final int appliedTags;
  final int skippedCollections;
  final int skippedItems;
  final int skippedTags;

  int get appliedTotal => appliedCollections + appliedItems + appliedTags;
  int get skippedTotal => skippedCollections + skippedItems + skippedTags;
}

class SyncServerChangesApplier {
  const SyncServerChangesApplier({
    required AppDatabase database,
    Duration timestampSkewTolerance = const Duration(seconds: 2),
  }) : _database = database,
       _timestampSkewTolerance = timestampSkewTolerance;

  final AppDatabase _database;
  final Duration _timestampSkewTolerance;

  Future<SyncServerChangeApplyResult> apply(SyncChangesPayload changes) async {
    var appliedCollections = 0;
    var appliedItems = 0;
    var appliedTags = 0;
    var skippedCollections = 0;
    var skippedItems = 0;
    var skippedTags = 0;
    final affectedCollectionIds = <String>{};

    await _database.transaction(() async {
      // Apply tags first so item-tag relations can be linked immediately.
      for (final payload in changes.tags) {
        final tagId = _asString(payload['id']);
        final tagName = _asString(payload['name']);
        if (tagId == null || tagId.isEmpty) {
          skippedTags++;
          continue;
        }

        if (await _hasPendingLocalOperation(
          entityType: 'tag',
          entityId: tagId,
        )) {
          skippedTags++;
          continue;
        }

        final existingTag = await (_database.select(
          _database.tags,
        )..where((tbl) => tbl.id.equals(tagId))).getSingleOrNull();
        final serverUpdatedAt = _asDate(payload['updatedAt']);
        if (_isServerPayloadOutdated(
          localUpdatedAt: existingTag?.updatedAt,
          serverUpdatedAt: serverUpdatedAt,
        )) {
          skippedTags++;
          continue;
        }

        if (_asBool(payload['isDeleted'])) {
          await (_database.delete(
            _database.tags,
          )..where((tbl) => tbl.id.equals(tagId))).go();
          appliedTags++;
          continue;
        }

        if (tagName == null || tagName.trim().isEmpty) {
          skippedTags++;
          continue;
        }

        final now = DateTime.now().toUtc();

        await _database
            .into(_database.tags)
            .insert(
              TagsCompanion(
                id: Value(tagId),
                name: Value(tagName),
                color: Value(_asString(payload['color'])),
                createdAt: Value(
                  _asDate(payload['createdAt']) ??
                      existingTag?.createdAt ??
                      now,
                ),
                updatedAt: Value(_asDate(payload['updatedAt']) ?? now),
              ),
              mode: InsertMode.insertOrReplace,
            );
        appliedTags++;
      }

      for (final payload in changes.collections) {
        final collectionId = _asString(payload['id']);
        if (collectionId == null || collectionId.isEmpty) {
          skippedCollections++;
          continue;
        }

        if (await _hasPendingLocalOperation(
          entityType: 'collection',
          entityId: collectionId,
        )) {
          skippedCollections++;
          continue;
        }

        final existingCollection = await (_database.select(
          _database.collections,
        )..where((tbl) => tbl.id.equals(collectionId))).getSingleOrNull();
        final serverUpdatedAt = _asDate(payload['updatedAt']);
        if (_isServerPayloadOutdated(
          localUpdatedAt: existingCollection?.updatedAt,
          serverUpdatedAt: serverUpdatedAt,
        )) {
          skippedCollections++;
          continue;
        }

        if (_asBool(payload['isDeleted'])) {
          await (_database.delete(
            _database.collections,
          )..where((tbl) => tbl.id.equals(collectionId))).go();
          appliedCollections++;
          continue;
        }

        final collectionName = _asString(payload['name']);
        final collectionType = _asString(payload['type']);
        if (collectionName == null ||
            collectionName.isEmpty ||
            collectionType == null ||
            collectionType.isEmpty) {
          skippedCollections++;
          continue;
        }

        final now = DateTime.now().toUtc();

        await _database
            .into(_database.collections)
            .insert(
              CollectionsCompanion(
                id: Value(collectionId),
                name: Value(collectionName),
                type: Value(collectionType),
                description: Value(_asString(payload['description'])),
                coverImagePath: Value(_asString(payload['coverImagePath'])),
                itemCount: Value(
                  _asInt(payload['itemCount']) ??
                      existingCollection?.itemCount ??
                      0,
                ),
                createdAt: Value(
                  _asDate(payload['createdAt']) ??
                      existingCollection?.createdAt ??
                      now,
                ),
                updatedAt: Value(_asDate(payload['updatedAt']) ?? now),
              ),
              mode: InsertMode.insertOrReplace,
            );
        appliedCollections++;
        affectedCollectionIds.add(collectionId);
      }

      for (final payload in changes.items) {
        final itemId = _asString(payload['id']);
        if (itemId == null || itemId.isEmpty) {
          skippedItems++;
          continue;
        }

        if (await _hasPendingLocalOperation(
          entityType: 'item',
          entityId: itemId,
        )) {
          skippedItems++;
          continue;
        }

        final existingItem = await (_database.select(
          _database.items,
        )..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();
        final serverUpdatedAt = _asDate(payload['updatedAt']);
        if (_isServerPayloadOutdated(
          localUpdatedAt: existingItem?.updatedAt,
          serverUpdatedAt: serverUpdatedAt,
        )) {
          skippedItems++;
          continue;
        }

        if (_asBool(payload['isDeleted'])) {
          if (existingItem != null) {
            affectedCollectionIds.add(existingItem.collectionId);
          }

          await (_database.delete(
            _database.items,
          )..where((tbl) => tbl.id.equals(itemId))).go();
          appliedItems++;
          continue;
        }

        final collectionId = _asString(payload['collectionId']);
        final title = _asString(payload['title']);
        if (collectionId == null ||
            collectionId.isEmpty ||
            title == null ||
            title.isEmpty) {
          skippedItems++;
          continue;
        }

        final existingCollection = await (_database.select(
          _database.collections,
        )..where((tbl) => tbl.id.equals(collectionId))).getSingleOrNull();
        if (existingCollection == null) {
          skippedItems++;
          continue;
        }

        final now = DateTime.now().toUtc();

        await _database
            .into(_database.items)
            .insert(
              ItemsCompanion(
                id: Value(itemId),
                collectionId: Value(collectionId),
                title: Value(title),
                barcode: Value(_asString(payload['barcode'])),
                coverImageUrl: Value(_asString(payload['coverImageUrl'])),
                coverImagePath: Value(_asString(payload['coverImagePath'])),
                description: Value(_asString(payload['description'])),
                notes: Value(_asString(payload['notes'])),
                metadata: Value(_asJsonString(payload['metadata'])),
                condition: Value(_asString(payload['condition'])),
                purchasePrice: Value(_asDouble(payload['purchasePrice'])),
                purchaseDate: Value(_asDate(payload['purchaseDate'])),
                currentValue: Value(_asDouble(payload['currentValue'])),
                location: Value(_asString(payload['location'])),
                isFavorite: Value(_asBool(payload['isFavorite'])),
                isWishlist: Value(_asBool(payload['isWishlist'])),
                sortOrder: Value(_asInt(payload['sortOrder']) ?? 0),
                quantity: Value(_asInt(payload['quantity']) ?? 1),
                createdAt: Value(
                  _asDate(payload['createdAt']) ??
                      existingItem?.createdAt ??
                      now,
                ),
                updatedAt: Value(_asDate(payload['updatedAt']) ?? now),
              ),
              mode: InsertMode.insertOrReplace,
            );
        appliedItems++;
        affectedCollectionIds.add(collectionId);
        if (existingItem != null && existingItem.collectionId != collectionId) {
          affectedCollectionIds.add(existingItem.collectionId);
        }

        await (_database.delete(
          _database.itemTags,
        )..where((tbl) => tbl.itemId.equals(itemId))).go();

        final tagIds = _asStringList(payload['tagIds']);
        if (tagIds.isNotEmpty) {
          final existingTags = await (_database.select(
            _database.tags,
          )..where((tbl) => tbl.id.isIn(tagIds))).get();
          for (final tag in existingTags) {
            await _database
                .into(_database.itemTags)
                .insert(
                  ItemTagsCompanion.insert(itemId: itemId, tagId: tag.id),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      }

      for (final collectionId in affectedCollectionIds) {
        final countRow = await _database
            .customSelect(
              'SELECT COUNT(*) AS item_count FROM items WHERE collection_id = ?',
              variables: [Variable.withString(collectionId)],
              readsFrom: {_database.items},
            )
            .getSingle();
        final count = countRow.read<int>('item_count');

        await (_database.update(
          _database.collections,
        )..where((tbl) => tbl.id.equals(collectionId))).write(
          CollectionsCompanion(
            itemCount: Value(count),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });

    return SyncServerChangeApplyResult(
      appliedCollections: appliedCollections,
      appliedItems: appliedItems,
      appliedTags: appliedTags,
      skippedCollections: skippedCollections,
      skippedItems: skippedItems,
      skippedTags: skippedTags,
    );
  }

  Future<bool> _hasPendingLocalOperation({
    required String entityType,
    required String entityId,
  }) async {
    final pending =
        await (_database.select(_database.syncOutbox)
              ..where((tbl) => tbl.entityType.equals(entityType))
              ..where((tbl) => tbl.entityId.equals(entityId)))
            .getSingleOrNull();
    return pending != null;
  }

  bool _isServerPayloadOutdated({
    required DateTime? localUpdatedAt,
    required DateTime? serverUpdatedAt,
  }) {
    if (localUpdatedAt == null || serverUpdatedAt == null) {
      return false;
    }

    final local = localUpdatedAt.toUtc();
    final server = serverUpdatedAt.toUtc();
    return local.isAfter(server.add(_timestampSkewTolerance));
  }

  bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  double? _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  String? _asString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return '$value';
  }

  List<String> _asStringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }

    return value
        .map(_asString)
        .whereType<String>()
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  String? _asJsonString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return '$value';
    }
  }

  DateTime? _asDate(Object? value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed?.toUtc();
    }
    return null;
  }
}
