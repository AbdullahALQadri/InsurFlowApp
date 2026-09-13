import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';

/// Every use case is a single callable class: one public method (`call`),
/// one input type, one output type. `Type` is what you get back on
/// success, `Params` is what the use case needs to run.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use for use cases that don't need any input (e.g. "get the list of
/// governorates").
class NoParams {
  const NoParams();
}
