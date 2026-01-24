import 'package:domain/src/failures/app_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class UseCase<T, Params> {
  Future<Either<AppException, T>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<Either<AppException, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
