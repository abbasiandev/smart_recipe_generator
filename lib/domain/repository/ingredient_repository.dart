import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entity/ingredient.dart';

abstract class IngredientRepository {
  Future<Either<Failure, List<Ingredient>>> getSavedIngredients();
  Future<Either<Failure, void>> saveIngredients(List<Ingredient> ingredients);
  Future<Either<Failure, void>> addIngredient(Ingredient ingredient);
  Future<Either<Failure, void>> removeIngredient(Ingredient ingredient);
  Future<Either<Failure, void>> clearAllIngredients();
}