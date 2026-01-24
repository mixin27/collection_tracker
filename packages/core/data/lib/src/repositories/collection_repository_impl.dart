import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionDao _dao;

  CollectionRepositoryImpl(this._dao);

  @override
  Future<Either<AppException, List<Collection>>> getCollections() async {
    try {
      final data = await _dao.getAllCollections();
      final collections = data.map(_mapToEntity).toList();
      return Right(collections);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load collections',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> getCollectionById(String id) async {
    try {
      final data = await _dao.getCollectionById(id);
      if (data == null) {
        return const Left(
          AppException.notFound(
            message: 'Collection not found',
            resourceType: 'Collection',
          ),
        );
      }
      return Right(_mapToEntity(data));
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to load collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> createCollection(
    Collection collection,
  ) async {
    try {
      final companion = _mapToCompanion(collection);
      await _dao.insertCollection(companion);
      return Right(collection);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to create collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Collection>> updateCollection(
    Collection collection,
  ) async {
    try {
      final companion = _mapToCompanion(collection);
      final success = await _dao.updateCollection(companion);
      if (success < 1) {
        return const Left(
          AppException.notFound(
            message: 'Collection not found',
            resourceType: 'Collection',
          ),
        );
      }
      return Right(collection);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to update collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteCollection(String id) async {
    try {
      await _dao.deleteCollection(id);
      return const Right(null);
    } catch (e, stack) {
      return Left(
        AppException.database(
          message: 'Failed to delete collection',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    return _dao.watchAllCollections().map(
      (data) => data.map(_mapToEntity).toList(),
    );
  }

  Collection _mapToEntity(CollectionData data) {
    return Collection(
      id: data.id,
      name: data.name,
      type: CollectionType.values.firstWhere(
        (e) => e.name == data.type,
        orElse: () => CollectionType.custom,
      ),
      description: data.description,
      coverImagePath: data.coverImagePath,
      itemCount: data.itemCount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  CollectionsCompanion _mapToCompanion(Collection entity) {
    return CollectionsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      description: Value(entity.description),
      coverImagePath: Value(entity.coverImagePath),
      itemCount: Value(entity.itemCount),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
