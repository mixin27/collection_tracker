import 'package:drift/drift.dart';

@DataClassName('TagData')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique().withLength(min: 1, max: 50)();
  TextColumn get color => text().nullable()(); // Hex color string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
