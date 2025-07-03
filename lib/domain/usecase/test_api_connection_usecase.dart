import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../repository/recipe_repository.dart';

class TestApiConnectionUseCase implements UseCase<bool, NoParams> {
  final RecipeRepository repository;

  TestApiConnectionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.testApiConnection();
  }
}