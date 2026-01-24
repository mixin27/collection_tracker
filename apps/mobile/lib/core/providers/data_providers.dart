import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database_providers.dart';

part 'data_providers.g.dart';

@riverpod
CollectionRepository collectionRepository(Ref ref) {
  final dao = ref.watch(collectionDaoProvider);
  return CollectionRepositoryImpl(dao);
}

@riverpod
ItemRepository itemRepository(Ref ref) {
  final dao = ref.watch(itemDaoProvider);
  return ItemRepositoryImpl(dao);
}
