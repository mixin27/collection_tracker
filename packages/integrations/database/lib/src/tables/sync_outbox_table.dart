import 'package:drift/drift.dart';

@DataClassName('SyncOutboxData')
class SyncOutbox extends Table {
  TextColumn get id => text()(); // Client-generated operation id (UUID)
  TextColumn get entityType => text().withLength(min: 1, max: 32)();
  TextColumn get entityId => text()();
  TextColumn get operationType => text().withLength(min: 1, max: 32)();
  TextColumn get payload => text()(); // JSON payload
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
