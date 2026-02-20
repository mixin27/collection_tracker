import 'package:database/src/daos/daos.dart';
import 'package:database/src/tables/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Collections, Items, Tags, ItemTags, ItemPriceHistory],
  daos: [CollectionDao, ItemDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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
