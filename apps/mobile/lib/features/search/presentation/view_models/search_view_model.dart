import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_view_model.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  Future<List<Item>> build(String collectionId, String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final repository = ref.watch(itemRepositoryProvider);
    final result = await repository.searchItems(
      collectionId: collectionId,
      query: query,
    );

    return result.fold((exception) => [], (items) => items);
  }

  Future<void> search(String newQuery) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      if (newQuery.trim().isEmpty) {
        return [];
      }

      final repository = ref.read(itemRepositoryProvider);
      final result = await repository.searchItems(
        collectionId: collectionId,
        query: newQuery,
      );

      return result.fold((exception) => throw exception, (items) => items);
    });
  }
}
