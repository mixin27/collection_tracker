import 'package:database/src/app_database.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';

part 'loan_dao.g.dart';

class ItemLoanWithItemData {
  const ItemLoanWithItemData({
    required this.loan,
    required this.item,
    required this.collection,
  });

  final ItemLoanData loan;
  final ItemData item;
  final CollectionData collection;
}

@DriftAccessor(tables: [ItemLoans, Items, Collections])
class LoanDao extends DatabaseAccessor<AppDatabase> with _$LoanDaoMixin {
  LoanDao(super.db);

  Future<List<ItemLoanData>> getAllLoans() {
    return (select(
      itemLoans,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.loanedAt)])).get();
  }

  Stream<List<ItemLoanWithItemData>> watchActiveLoans() {
    final query =
        select(itemLoans).join([
            innerJoin(items, items.id.equalsExp(itemLoans.itemId)),
            innerJoin(
              collections,
              collections.id.equalsExp(items.collectionId),
            ),
          ])
          ..where(itemLoans.returnedAt.isNull())
          ..orderBy([
            OrderingTerm.asc(itemLoans.dueAt),
            OrderingTerm.desc(itemLoans.loanedAt),
          ]);

    return query.watch().map(_mapJoinedRows);
  }

  Stream<List<ItemLoanWithItemData>> watchLoanHistory({int limit = 200}) {
    final query =
        select(itemLoans).join([
            innerJoin(items, items.id.equalsExp(itemLoans.itemId)),
            innerJoin(
              collections,
              collections.id.equalsExp(items.collectionId),
            ),
          ])
          ..where(itemLoans.returnedAt.isNotNull())
          ..orderBy([
            OrderingTerm.desc(itemLoans.returnedAt),
            OrderingTerm.desc(itemLoans.loanedAt),
          ])
          ..limit(limit);

    return query.watch().map(_mapJoinedRows);
  }

  Stream<ItemLoanWithItemData?> watchActiveLoanForItem(String itemId) {
    final query =
        select(itemLoans).join([
            innerJoin(items, items.id.equalsExp(itemLoans.itemId)),
            innerJoin(
              collections,
              collections.id.equalsExp(items.collectionId),
            ),
          ])
          ..where(
            itemLoans.itemId.equals(itemId) & itemLoans.returnedAt.isNull(),
          )
          ..orderBy([OrderingTerm.desc(itemLoans.loanedAt)])
          ..limit(1);

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return _mapJoinedRow(rows.first);
    });
  }

  Future<ItemLoanData?> getLoanById(String id) {
    return (select(
      itemLoans,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<ItemLoanWithItemData?> getLoanWithItemById(String loanId) async {
    final query =
        select(itemLoans).join([
            innerJoin(items, items.id.equalsExp(itemLoans.itemId)),
            innerJoin(
              collections,
              collections.id.equalsExp(items.collectionId),
            ),
          ])
          ..where(itemLoans.id.equals(loanId))
          ..limit(1);

    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }

    return _mapJoinedRow(rows.first);
  }

  Future<ItemLoanData?> getActiveLoanByItemId(String itemId) {
    return (select(itemLoans)
          ..where((tbl) => tbl.itemId.equals(itemId) & tbl.returnedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.loanedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<ItemLoanWithItemData?> getActiveLoanWithItemByItemId(
    String itemId,
  ) async {
    final query =
        select(itemLoans).join([
            innerJoin(items, items.id.equalsExp(itemLoans.itemId)),
            innerJoin(
              collections,
              collections.id.equalsExp(items.collectionId),
            ),
          ])
          ..where(
            itemLoans.itemId.equals(itemId) & itemLoans.returnedAt.isNull(),
          )
          ..orderBy([OrderingTerm.desc(itemLoans.loanedAt)])
          ..limit(1);

    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }
    return _mapJoinedRow(rows.first);
  }

  Future<void> insertLoan(ItemLoansCompanion loan) {
    return into(itemLoans).insert(loan, mode: InsertMode.insertOrReplace);
  }

  Future<int> updateLoan(ItemLoansCompanion loan) {
    return (update(
      itemLoans,
    )..where((tbl) => tbl.id.equals(loan.id.value))).write(loan);
  }

  Future<int> markReturned({
    required String loanId,
    required DateTime returnedAt,
  }) {
    return (update(itemLoans)..where((tbl) => tbl.id.equals(loanId))).write(
      ItemLoansCompanion(
        returnedAt: Value(returnedAt),
        updatedAt: Value(returnedAt),
      ),
    );
  }

  Future<int> deleteLoan(String loanId) {
    return (delete(itemLoans)..where((tbl) => tbl.id.equals(loanId))).go();
  }

  List<ItemLoanWithItemData> _mapJoinedRows(List<TypedResult> rows) {
    return rows.map(_mapJoinedRow).toList(growable: false);
  }

  ItemLoanWithItemData _mapJoinedRow(TypedResult row) {
    return ItemLoanWithItemData(
      loan: row.readTable(itemLoans),
      item: row.readTable(items),
      collection: row.readTable(collections),
    );
  }
}
