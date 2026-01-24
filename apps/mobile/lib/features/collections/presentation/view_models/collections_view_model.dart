import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'collections_view_model.g.dart';

@riverpod
class CollectionsViewModel extends _$CollectionsViewModel {
  @override
  Stream<List<Collection>> build() {
    final repository = ref.watch(collectionRepositoryProvider);
    return repository.watchCollections();
  }

  Future<void> createCollection({
    required String name,
    required CollectionType type,
    String? description,
  }) async {
    final repository = ref.read(collectionRepositoryProvider);

    final collection = Collection(
      id: const Uuid().v4(),
      name: name,
      type: type,
      description: description,
      itemCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repository.createCollection(collection);
  }

  Future<void> updateCollection(Collection collection) async {
    final repository = ref.read(collectionRepositoryProvider);

    final updated = collection.copyWith(updatedAt: DateTime.now());

    await repository.updateCollection(updated);
  }

  Future<void> deleteCollection(String id) async {
    final repository = ref.read(collectionRepositoryProvider);
    await repository.deleteCollection(id);
  }
}

@riverpod
Future<Collection?> collectionDetail(Ref ref, String id) async {
  final repository = ref.watch(collectionRepositoryProvider);
  final result = await repository.getCollectionById(id);

  return result.fold((exception) => null, (collection) => collection);
}
