import 'package:collection_tracker/core/providers/providers.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'items_view_model.g.dart';

@riverpod
Stream<List<Item>> itemsList(Ref ref, String collectionId) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchItems(collectionId);
}

@riverpod
Future<void> createItem(
  Ref ref, {
  required String collectionId,
  required String title,
  String? barcode,
  String? description,
  String? coverImageUrl,
  String? coverImagePath,
}) async {
  final repository = ref.read(itemRepositoryProvider);

  final item = Item(
    id: const Uuid().v4(),
    collectionId: collectionId,
    title: title,
    barcode: barcode,
    description: description,
    coverImageUrl: coverImageUrl,
    coverImagePath: coverImagePath,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final result = await repository.createItem(item);

  result.fold((exception) => throw exception, (_) => null);
}

@riverpod
Future<void> updateItem(Ref ref, Item item) async {
  final repository = ref.read(itemRepositoryProvider);

  final updated = item.copyWith(updatedAt: DateTime.now());

  final result = await repository.updateItem(updated);

  result.fold((exception) => throw exception, (_) => null);
}

@riverpod
Future<void> deleteItem(Ref ref, String id) async {
  final repository = ref.read(itemRepositoryProvider);
  final result = await repository.deleteItem(id);

  result.fold((exception) => throw exception, (_) => null);
}

@riverpod
Stream<Item?> itemDetail(Ref ref, String itemId) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchItemById(itemId);
}
