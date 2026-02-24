import 'dart:math';

import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../sync/outbox_sync_writer.dart';

class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl(this._dao, {SyncDao? syncDao})
    : _syncOutboxWriter = syncDao != null ? SyncOutboxWriter(syncDao) : null;

  final LoanDao _dao;
  final Random _random = Random();
  final SyncOutboxWriter? _syncOutboxWriter;

  @override
  Stream<List<LoanRecord>> watchActiveLoans() {
    return _dao.watchActiveLoans().map(
      (rows) => rows.map(_mapToEntity).toList(growable: false),
    );
  }

  @override
  Stream<List<LoanRecord>> watchLoanHistory({int limit = 200}) {
    return _dao
        .watchLoanHistory(limit: limit)
        .map((rows) => rows.map(_mapToEntity).toList(growable: false));
  }

  @override
  Stream<LoanRecord?> watchActiveLoanForItem(String itemId) {
    return _dao
        .watchActiveLoanForItem(itemId)
        .map((row) => row == null ? null : _mapToEntity(row));
  }

  @override
  Future<Either<AppException, LoanRecord>> createLoan({
    required String itemId,
    required String borrowerName,
    String? borrowerContact,
    String? notes,
    DateTime? dueAt,
  }) async {
    final normalizedBorrower = borrowerName.trim();
    if (normalizedBorrower.isEmpty) {
      return const Left(
        AppException.validation(message: 'Borrower name is required.'),
      );
    }

    try {
      final existingActive = await _dao.getActiveLoanByItemId(itemId);
      if (existingActive != null) {
        return const Left(
          AppException.business(
            message: 'This item is already on loan.',
            code: 'item_already_loaned',
          ),
        );
      }

      final now = DateTime.now();
      if (dueAt != null && dueAt.isBefore(now)) {
        return const Left(
          AppException.validation(
            message: 'Due date must be in the future.',
            fieldErrors: {'dueAt': 'Due date must be in the future.'},
          ),
        );
      }

      final id = _generateLoanId(itemId);
      await _dao.insertLoan(
        ItemLoansCompanion.insert(
          id: id,
          itemId: itemId,
          borrowerName: normalizedBorrower,
          borrowerContact: Value(_normalizeNullableText(borrowerContact)),
          notes: Value(_normalizeNullableText(notes)),
          loanedAt: now,
          dueAt: Value(dueAt),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final created = await _dao.getLoanWithItemById(id);
      if (created == null) {
        return const Left(
          AppException.notFound(
            message: 'Loan was created but could not be loaded.',
            resourceType: 'Loan',
          ),
        );
      }

      final createdEntity = _mapToEntity(created);
      await _queueLoanUpsert(createdEntity);
      return Right(createdEntity);
    } catch (error, stackTrace) {
      return Left(
        AppException.database(
          message: 'Failed to create loan',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, LoanRecord>> markLoanReturned({
    required String loanId,
    DateTime? returnedAt,
  }) async {
    try {
      final existing = await _dao.getLoanWithItemById(loanId);
      if (existing == null) {
        return const Left(
          AppException.notFound(
            message: 'Loan not found',
            resourceType: 'Loan',
          ),
        );
      }

      if (existing.loan.returnedAt != null) {
        return Right(_mapToEntity(existing));
      }

      final effectiveReturnedAt = returnedAt ?? DateTime.now();
      final rowsAffected = await _dao.markReturned(
        loanId: loanId,
        returnedAt: effectiveReturnedAt,
      );
      if (rowsAffected < 1) {
        return const Left(
          AppException.notFound(
            message: 'Loan not found',
            resourceType: 'Loan',
          ),
        );
      }

      final updated = await _dao.getLoanWithItemById(loanId);
      if (updated == null) {
        return const Left(
          AppException.notFound(
            message: 'Loan not found',
            resourceType: 'Loan',
          ),
        );
      }

      final updatedEntity = _mapToEntity(updated);
      await _queueLoanUpsert(updatedEntity);
      return Right(updatedEntity);
    } catch (error, stackTrace) {
      return Left(
        AppException.database(
          message: 'Failed to update loan status',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteLoan(String loanId) async {
    try {
      final existing = await _dao.getLoanWithItemById(loanId);
      final rowsAffected = await _dao.deleteLoan(loanId);
      if (rowsAffected < 1) {
        return const Left(
          AppException.notFound(
            message: 'Loan not found',
            resourceType: 'Loan',
          ),
        );
      }

      if (existing != null) {
        await _queueLoanDelete(_mapToEntity(existing));
      }

      return const Right(null);
    } catch (error, stackTrace) {
      return Left(
        AppException.database(
          message: 'Failed to delete loan',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  LoanRecord _mapToEntity(ItemLoanWithItemData row) {
    return LoanRecord(
      id: row.loan.id,
      itemId: row.item.id,
      itemTitle: row.item.title,
      collectionId: row.item.collectionId,
      collectionName: row.collection.name,
      itemCoverImageUrl: row.item.coverImageUrl,
      itemCoverImagePath: row.item.coverImagePath,
      borrowerName: row.loan.borrowerName,
      borrowerContact: row.loan.borrowerContact,
      notes: row.loan.notes,
      loanedAt: row.loan.loanedAt,
      dueAt: row.loan.dueAt,
      returnedAt: row.loan.returnedAt,
      createdAt: row.loan.createdAt,
      updatedAt: row.loan.updatedAt,
    );
  }

  String _generateLoanId(String itemId) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomPart = _random.nextInt(1 << 32).toRadixString(16);
    return 'loan_${itemId}_$timestamp$randomPart';
  }

  String? _normalizeNullableText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<void> _queueLoanUpsert(LoanRecord loan) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    try {
      await writer.queueUpsert(
        entityType: 'loan',
        entityId: loan.id,
        payload: _loanSyncPayload(loan: loan),
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Future<void> _queueLoanDelete(LoanRecord loan) async {
    final writer = _syncOutboxWriter;
    if (writer == null) {
      return;
    }

    final deletedAt = DateTime.now();
    try {
      await writer.queueDelete(
        entityType: 'loan',
        entityId: loan.id,
        payload: _loanSyncPayload(
          loan: loan,
          isDeleted: true,
          deletedAt: deletedAt,
          updatedAt: deletedAt,
        ),
      );
    } catch (_) {
      // Keep local write successful even if sync queue persistence fails.
    }
  }

  Map<String, dynamic> _loanSyncPayload({
    required LoanRecord loan,
    bool isDeleted = false,
    DateTime? deletedAt,
    DateTime? updatedAt,
  }) {
    final effectiveUpdatedAt = updatedAt ?? loan.updatedAt;
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
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt.toUtc().toIso8601String(),
      'createdAt': loan.createdAt.toUtc().toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toUtc().toIso8601String(),
    };
  }
}
