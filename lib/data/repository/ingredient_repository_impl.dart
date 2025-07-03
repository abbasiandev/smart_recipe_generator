import 'package:dartz/dartz.dart';

import '../../core/error/error_handler.dart';
import '../../core/error/failure.dart';
import '../../domain/entity/ingredient.dart';
import '../../domain/repository/ingredient_repository.dart';
import '../datasource/local_data_source.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final LocalDataSource localDataSource;

  IngredientRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Ingredient>>> getSavedIngredients() async {
    try {
      final ingredients = await localDataSource.getSavedIngredients();
      return Right(ingredients);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to load saved ingredients'));
    }
  }

  @override
  Future<Either<Failure, void>> saveIngredients(List<Ingredient> ingredients) async {
    try {
      await localDataSource.saveIngredients(ingredients);
      return const Right(null);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to save ingredients'));
    }
  }

  @override
  Future<Either<Failure, void>> addIngredient(Ingredient ingredient) async {
    try {
      if (ingredient.name.trim().isEmpty) {
        return const Left(ValidationFailure('Ingredient name cannot be empty'));
      }

      final currentIngredients = await localDataSource.getSavedIngredients();

      final exists = currentIngredients.any((existing) =>
      existing.name.toLowerCase().trim() == ingredient.name.toLowerCase().trim());

      if (exists) {
        return const Left(ValidationFailure('Ingredient already exists'));
      }

      currentIngredients.add(ingredient);
      await localDataSource.saveIngredients(currentIngredients);

      return const Right(null);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to add ingredient'));
    }
  }

  @override
  Future<Either<Failure, void>> removeIngredient(Ingredient ingredient) async {
    try {
      if (ingredient.name.trim().isEmpty) {
        return const Left(ValidationFailure('Invalid ingredient to remove'));
      }

      final currentIngredients = await localDataSource.getSavedIngredients();

      final initialLength = currentIngredients.length;
      currentIngredients.removeWhere((existing) =>
      existing.name.toLowerCase().trim() == ingredient.name.toLowerCase().trim());

      if (currentIngredients.length == initialLength) {
        return const Left(ValidationFailure('Ingredient not found'));
      }

      await localDataSource.saveIngredients(currentIngredients);
      return const Right(null);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to remove ingredient'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllIngredients() async {
    try {
      await localDataSource.saveIngredients([]);
      return const Right(null);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to clear ingredients'));
    }
  }
}