import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:database/database.dart';

part 'database_providers.g.dart';

@riverpod
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
}

@riverpod
CollectionDao collectionDao(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.collectionDao;
}

@riverpod
ItemDao itemDao(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.itemDao;
}
