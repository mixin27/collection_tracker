import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:app_analytics/app_analytics.dart';

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

    await AnalyticsService.instance.track(
      AnalyticsEvent.custom(
        name: 'collection_created',
        properties: {
          'collection_id': collection.id,
          'collection_type': collection.type.name,
        },
      ),
    );
  }

  Future<void> updateCollection(Collection collection) async {
    final repository = ref.read(collectionRepositoryProvider);

    final updated = collection.copyWith(updatedAt: DateTime.now());

    await repository.updateCollection(updated);
  }

  Future<void> deleteCollection(String id) async {
    final repository = ref.read(collectionRepositoryProvider);
    await repository.deleteCollection(id);

    await AnalyticsService.instance.track(
      AnalyticsEvent.custom(
        name: 'collection_deleted',
        properties: {'collection_id': id},
      ),
    );
  }
}

@riverpod
Stream<Collection?> collectionDetail(Ref ref, String id) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.watchCollectionById(id);
}
