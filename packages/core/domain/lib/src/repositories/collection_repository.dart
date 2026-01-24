import 'package:domain/src/entities/collection.dart';
import 'package:domain/src/failures/app_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class CollectionRepository {
  Future<Either<AppException, List<Collection>>> getCollections();
  Future<Either<AppException, Collection>> getCollectionById(String id);
  Future<Either<AppException, Collection>> createCollection(
    Collection collection,
  );
  Future<Either<AppException, Collection>> updateCollection(
    Collection collection,
  );
  Future<Either<AppException, void>> deleteCollection(String id);
  Stream<List<Collection>> watchCollections();
}
