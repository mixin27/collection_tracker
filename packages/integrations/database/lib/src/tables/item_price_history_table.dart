import 'package:drift/drift.dart';

import 'items_table.dart';

@DataClassName('ItemPriceHistoryData')
class ItemPriceHistory extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  RealColumn get value => real()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  @override
  Set<Column> get primaryKey => {id};
}
