import 'package:drift/drift.dart';

@DataClassName('SyncStateData')
class SyncState extends Table {
  TextColumn get id =>
      text().withDefault(const Constant('primary'))(); // single-row table
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptedSyncAt => dateTime().nullable()();
  TextColumn get lastRemoteCursor => text().nullable()();
  IntColumn get consecutiveFailures =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
