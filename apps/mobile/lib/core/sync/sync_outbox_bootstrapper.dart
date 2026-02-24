import 'dart:convert';

import 'package:database/database.dart';
import 'package:storage/storage.dart';

class SyncOutboxBootstrapResult {
  const SyncOutboxBootstrapResult({
    required this.collectionOperations,
    required this.itemOperations,
    required this.tagOperations,
    required this.loanOperations,
    required this.skipped,
  });

  final int collectionOperations;
  final int itemOperations;
  final int tagOperations;
  final int loanOperations;
  final bool skipped;

  int get totalOperations =>
      collectionOperations + itemOperations + tagOperations + loanOperations;
}

class SyncOutboxBootstrapper {
  static const _seedStateKey = 'sync_initial_outbox_seed_completed_v1';
  static const _seedOperationCountKey =
      'sync_initial_outbox_seed_operation_count_v1';

  const SyncOutboxBootstrapper({
    required SyncDao syncDao,
    required CollectionDao collectionDao,
    required ItemDao itemDao,
    required LoanDao loanDao,
  }) : _syncDao = syncDao,
       _collectionDao = collectionDao,
       _itemDao = itemDao,
       _loanDao = loanDao;

  final SyncDao _syncDao;
  final CollectionDao _collectionDao;
  final ItemDao _itemDao;
  final LoanDao _loanDao;

  Future<SyncOutboxBootstrapResult> seedFromLocalDataIfNeeded() async {
    final pending = await _syncDao.getPendingOperations(limit: 1);
    if (pending.isNotEmpty) {
      return const SyncOutboxBootstrapResult(
        collectionOperations: 0,
        itemOperations: 0,
        tagOperations: 0,
        loanOperations: 0,
        skipped: true,
      );
    }

    final seedAlreadyCompleted =
        PrefsStorageService.instance.readSync<bool>(_seedStateKey) ?? false;
    final previouslySeededOperationCount =
        PrefsStorageService.instance.readSync<int>(_seedOperationCountKey) ?? 0;

    // If an earlier seed run queued 0 operations, allow reseeding when data
    // appears later (for example, data existed before sync was enabled).
    if (seedAlreadyCompleted && previouslySeededOperationCount > 0) {
      return const SyncOutboxBootstrapResult(
        collectionOperations: 0,
        itemOperations: 0,
        tagOperations: 0,
        loanOperations: 0,
        skipped: true,
      );
    }

    final result = await _seedFromLocalData();
    await PrefsStorageService.instance.save<bool>(_seedStateKey, true);
    await PrefsStorageService.instance.save<int>(
      _seedOperationCountKey,
      result.totalOperations,
    );
    return result;
  }

  Future<SyncOutboxBootstrapResult> rebuildFromLocalData() async {
    await _syncDao.clearOutbox();
    final result = await _seedFromLocalData();
    await PrefsStorageService.instance.save<bool>(_seedStateKey, true);
    await PrefsStorageService.instance.save<int>(
      _seedOperationCountKey,
      result.totalOperations,
    );
    return result;
  }

  Future<SyncOutboxBootstrapResult> _seedFromLocalData() async {
    final collections = await _collectionDao.getAllCollections();
    final tags = await _itemDao.getAllTags();
    final tagIdByName = <String, String>{
      for (final tag in tags) tag.name: tag.id,
    };

    var collectionOperations = 0;
    var itemOperations = 0;
    var tagOperations = 0;
    var loanOperations = 0;

    for (final tag in tags) {
      await _queueUpsert(
        entityType: 'tag',
        entityId: tag.id,
        payload: _tagPayload(tag),
      );
      tagOperations++;
    }

    for (final collection in collections) {
      await _queueUpsert(
        entityType: 'collection',
        entityId: collection.id,
        payload: _collectionPayload(collection),
      );
      collectionOperations++;
    }

    for (final collection in collections) {
      final itemRows = await _itemDao.getItemsWithTags(collection.id);
      for (final row in itemRows) {
        final item = row.$1;
        final tagNames = row.$2;
        final tagIds = tagNames
            .map((tagName) => tagIdByName[tagName])
            .whereType<String>()
            .toList(growable: false);

        await _queueUpsert(
          entityType: 'item',
          entityId: item.id,
          payload: _itemPayload(item: item, tagIds: tagIds),
        );
        itemOperations++;
      }
    }

    final loans = await _loanDao.getAllLoans();
    for (final loan in loans) {
      await _queueUpsert(
        entityType: 'loan',
        entityId: loan.id,
        payload: _loanPayload(loan),
      );
      loanOperations++;
    }

    return SyncOutboxBootstrapResult(
      collectionOperations: collectionOperations,
      itemOperations: itemOperations,
      tagOperations: tagOperations,
      loanOperations: loanOperations,
      skipped: false,
    );
  }

  Future<void> _queueUpsert({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    await _syncDao.markOperationSynced(
      _operationId(entityType, entityId, 'delete'),
    );
    await _syncDao.enqueueOperation(
      id: _operationId(entityType, entityId, 'upsert'),
      entityType: entityType,
      entityId: entityId,
      operationType: 'upsert',
      payload: jsonEncode(payload),
    );
  }

  String _operationId(
    String entityType,
    String entityId,
    String operationType,
  ) {
    return '$entityType:$entityId:$operationType';
  }

  Map<String, dynamic> _collectionPayload(CollectionData collection) {
    return {
      'id': collection.id,
      'name': collection.name,
      'type': collection.type,
      'description': collection.description,
      'coverImagePath': collection.coverImagePath,
      'itemCount': collection.itemCount,
      'version': 1,
      'isDeleted': false,
      'createdAt': collection.createdAt.toUtc().toIso8601String(),
      'updatedAt': collection.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _itemPayload({
    required ItemData item,
    required List<String> tagIds,
  }) {
    return {
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
      'purchaseDate': item.purchaseDate?.toUtc().toIso8601String(),
      'currentValue': item.currentValue,
      'location': item.location,
      'isFavorite': item.isFavorite,
      'isWishlist': item.isWishlist,
      'sortOrder': item.sortOrder,
      'quantity': item.quantity,
      'version': 1,
      'isDeleted': false,
      'createdAt': item.createdAt.toUtc().toIso8601String(),
      'updatedAt': item.updatedAt.toUtc().toIso8601String(),
      'tagIds': tagIds,
    };
  }

  Map<String, dynamic> _tagPayload(TagData tag) {
    return {
      'id': tag.id,
      'name': tag.name,
      'color': tag.color,
      'version': 1,
      'isDeleted': false,
      'createdAt': tag.createdAt.toUtc().toIso8601String(),
      'updatedAt': tag.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _loanPayload(ItemLoanData loan) {
    return {
      'id': loan.id,
      'itemId': loan.itemId,
      'borrowerName': loan.borrowerName,
      'borrowerContact': loan.borrowerContact,
      'notes': loan.notes,
      'loanedAt': loan.loanedAt.toUtc().toIso8601String(),
      'dueAt': loan.dueAt?.toUtc().toIso8601String(),
      'returnedAt': loan.returnedAt?.toUtc().toIso8601String(),
      'version': 1,
      'isDeleted': false,
      'createdAt': loan.createdAt.toUtc().toIso8601String(),
      'updatedAt': loan.updatedAt.toUtc().toIso8601String(),
    };
  }
}
