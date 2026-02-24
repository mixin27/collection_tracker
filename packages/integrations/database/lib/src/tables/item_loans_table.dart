import 'package:drift/drift.dart';

import 'items_table.dart';

@DataClassName('ItemLoanData')
class ItemLoans extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get borrowerName => text().withLength(min: 1, max: 120)();
  TextColumn get borrowerContact => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get loanedAt => dateTime()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
