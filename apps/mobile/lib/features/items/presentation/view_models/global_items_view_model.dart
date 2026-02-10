import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_items_view_model.g.dart';

@riverpod
Stream<List<Item>> allFavoriteItems(Ref ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchAllFavoriteItems();
}

@riverpod
Stream<List<Item>> allWishlistItems(Ref ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchAllWishlistItems();
}
