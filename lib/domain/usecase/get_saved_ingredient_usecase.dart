import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../entity/ingredient.dart';
import '../repository/ingredient_repository.dart';

class GetSavedIngredientsUseCase implements UseCase<List<Ingredient>, NoParams> {
  final IngredientRepository repository;

  GetSavedIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ingredient>>> call(NoParams params) async {
    return await repository.getSavedIngredients();
  }
}