import 'package:domain/src/entities/collection.dart';
import 'package:domain/src/failures/app_exception.dart';
import 'package:domain/src/repositories/collection_repository.dart';
import 'package:domain/src/usecases/base_usecase.dart';
import 'package:fpdart/fpdart.dart';

class CreateCollectionParams {
  final Collection collection;

  const CreateCollectionParams({required this.collection});
}

class CreateCollectionUseCase
    extends UseCase<Collection, CreateCollectionParams> {
  final CollectionRepository _repository;

  CreateCollectionUseCase(this._repository);

  @override
  Future<Either<AppException, Collection>> call(CreateCollectionParams params) {
    return _repository.createCollection(params.collection);
  }
}
