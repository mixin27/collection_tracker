import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_detail_view_model.g.dart';

@riverpod
Stream<Collection?> collectionStream(Ref ref, String id) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.watchCollectionById(id);
}
