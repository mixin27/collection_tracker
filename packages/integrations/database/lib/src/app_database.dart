import 'package:database/src/daos/daos.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Collections,
    Items,
    Tags,
    ItemTags,
    ItemPriceHistory,
    ItemLoans,
    SyncOutbox,
    SyncState,
  ],
  daos: [CollectionDao, ItemDao, LoanDao, SyncDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Add indexes here
        await customStatement(
          'CREATE INDEX idx_collections_name ON collections(name);',
        );
        await customStatement('CREATE INDEX idx_items_name ON items(title);');
        await customStatement(
          'CREATE INDEX idx_item_price_history_item_time '
          'ON item_price_history(item_id, recorded_at DESC);',
        );
        await customStatement(
          'CREATE INDEX idx_item_loans_item_active '
          'ON item_loans(item_id, returned_at);',
        );
        await customStatement(
          'CREATE INDEX idx_item_loans_due_at ON item_loans(due_at);',
        );
        await customStatement(
          'CREATE INDEX idx_sync_outbox_created_at ON sync_outbox(created_at);',
        );
        await customStatement(
          'CREATE INDEX idx_sync_outbox_entity '
          'ON sync_outbox(entity_type, entity_id);',
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(items, items.sortOrder);
        }

        if (from < 3) {
          await m.addColumn(items, items.isWishlist);
        }

        if (from < 4) {
          await m.createTable(tags);
          await m.createTable(itemTags);
        }

        if (from < 5) {
          await m.createTable(itemPriceHistory);
          await customStatement(
            'CREATE INDEX idx_item_price_history_item_time '
            'ON item_price_history(item_id, recorded_at DESC);',
          );
        }

        if (from < 6) {
          await m.createTable(syncOutbox);
          await m.createTable(syncState);
          await customStatement(
            'CREATE INDEX idx_sync_outbox_created_at ON sync_outbox(created_at);',
          );
          await customStatement(
            'CREATE INDEX idx_sync_outbox_entity '
            'ON sync_outbox(entity_type, entity_id);',
          );
        }

        if (from < 7) {
          await m.addColumn(syncState, syncState.nextRetryAt);
        }

        if (from < 8) {
          await m.createTable(itemLoans);
          await customStatement(
            'CREATE INDEX idx_item_loans_item_active '
            'ON item_loans(item_id, returned_at);',
          );
          await customStatement(
            'CREATE INDEX idx_item_loans_due_at ON item_loans(due_at);',
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'cashbook',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
