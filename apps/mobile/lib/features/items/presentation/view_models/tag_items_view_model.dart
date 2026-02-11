import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_items_view_model.g.dart';

@riverpod
Stream<List<Item>> tagItems(Ref ref, String tagName) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchItemsByTag(tagName);
}
