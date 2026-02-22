import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database_providers.dart';
import 'sync_providers.dart';

part 'data_providers.g.dart';

@riverpod
CollectionRepository collectionRepository(Ref ref) {
  final dao = ref.watch(collectionDaoProvider);
  final syncDao = ref.watch(syncDaoProvider);
  return CollectionRepositoryImpl(dao, syncDao: syncDao);
}

@riverpod
ItemRepository itemRepository(Ref ref) {
  final dao = ref.watch(itemDaoProvider);
  final syncDao = ref.watch(syncDaoProvider);
  return ItemRepositoryImpl(dao, syncDao: syncDao);
}
