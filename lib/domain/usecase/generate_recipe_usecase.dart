import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../entity/ingredient.dart';
import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class GenerateRecipesUseCase implements UseCase<List<Recipe>, GenerateRecipesParams> {
  final RecipeRepository repository;

  GenerateRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(GenerateRecipesParams params) async {
    return await repository.generateRecipes(params.ingredients);
  }
}

class GenerateRecipesParams extends Equatable {
  final List<Ingredient> ingredients;

  const GenerateRecipesParams({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}