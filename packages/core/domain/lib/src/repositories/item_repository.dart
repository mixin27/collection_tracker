import 'package:domain/src/entities/item.dart';
import 'package:domain/src/failures/app_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ItemRepository {
  Future<Either<AppException, List<Item>>> getItems({
    required String collectionId,
    int? limit,
    int? offset,
  });

  Future<Either<AppException, Item>> getItemById(String id);
  Future<Either<AppException, Item>> createItem(Item item);
  Future<Either<AppException, Item>> updateItem(Item item);
  Future<Either<AppException, void>> deleteItem(String id);

  Stream<List<Item>> watchItems(String collectionId);
  Stream<Item?> watchItemById(String id);

  Future<Either<AppException, List<Item>>> searchItems({
    required String collectionId,
    required String query,
  });
}
