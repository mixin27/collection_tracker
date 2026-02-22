import 'dart:convert';

import 'package:database/database.dart';

class SyncOutboxWriter {
  SyncOutboxWriter(this._syncDao);

  final SyncDao _syncDao;

  Future<void> queueUpsert({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    return _queue(
      entityType: entityType,
      entityId: entityId,
      operationType: _upsertOp,
      payload: payload,
    );
  }

  Future<void> queueDelete({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    return _queue(
      entityType: entityType,
      entityId: entityId,
      operationType: _deleteOp,
      payload: payload,
    );
  }

  Future<void> _queue({
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, dynamic> payload,
  }) async {
    final oppositeOperation = operationType == _deleteOp
        ? _upsertOp
        : _deleteOp;

    await _syncDao.markOperationSynced(
      _operationId(entityType, entityId, oppositeOperation),
    );
    await _syncDao.enqueueOperation(
      id: _operationId(entityType, entityId, operationType),
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
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

  static const String _upsertOp = 'upsert';
  static const String _deleteOp = 'delete';
}
