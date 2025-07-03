import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entity/ingredient.dart';
import '../entity/recipe.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> generateRecipes(List<Ingredient> ingredients);
  Future<Either<Failure, List<Recipe>>> getSampleRecipes(List<Ingredient> ingredients);
  Future<Either<Failure, bool>> testApiConnection();
  Future<Either<Failure, List<Recipe>>> getCachedRecipes();
  Future<Either<Failure, void>> cacheRecipes(List<Recipe> recipes);
}
