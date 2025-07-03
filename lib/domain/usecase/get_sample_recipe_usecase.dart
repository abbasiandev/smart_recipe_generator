import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../entity/ingredient.dart';
import '../entity/recipe.dart';
import '../repository/recipe_repository.dart';

class GetSampleRecipesUseCase implements UseCase<List<Recipe>, GetSampleRecipesParams> {
  final RecipeRepository repository;

  GetSampleRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(GetSampleRecipesParams params) async {
    return await repository.getSampleRecipes(params.ingredients);
  }
}

class GetSampleRecipesParams extends Equatable {
  final List<Ingredient> ingredients;

  const GetSampleRecipesParams({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}