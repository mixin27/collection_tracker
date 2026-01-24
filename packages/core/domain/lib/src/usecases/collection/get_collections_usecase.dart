import 'package:domain/src/entities/collection.dart';
import 'package:domain/src/failures/app_exception.dart';
import 'package:domain/src/repositories/collection_repository.dart';
import 'package:domain/src/usecases/base_usecase.dart';
import 'package:fpdart/fpdart.dart';

class GetCollectionsUseCase extends UseCase<List<Collection>, NoParams> {
  final CollectionRepository _repository;

  GetCollectionsUseCase(this._repository);

  @override
  Future<Either<AppException, List<Collection>>> call(NoParams params) {
    return _repository.getCollections();
  }
}
