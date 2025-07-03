import 'package:dartz/dartz.dart';
import 'package:smart_recipe_generator/domain/repository/recipe_repository.dart';

import '../../core/error/error_handler.dart';
import '../../core/error/failure.dart';
import '../../core/network/network_info.dart';
import '../../domain/entity/ingredient.dart';
import '../../domain/entity/recipe.dart';
import '../datasource/local_data_source.dart';
import '../datasource/remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Recipe>>> generateRecipes(List<Ingredient> ingredients) async {
    try {
      if (ingredients.isEmpty) {
        return const Left(ValidationFailure('Please add at least one ingredient'));
      }

      if (!(await networkInfo.isConnected)) {
        return const Left(NetworkFailure('No internet connection available'));
      }

      final recipes = await remoteDataSource.generateRecipes(ingredients);

      try {
        await localDataSource.cacheRecipes(recipes);
      } catch (cacheError) {
        ErrorHandler.handleError(cacheError, StackTrace.current);
      }

      return Right(recipes);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(_mapErrorToFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getSampleRecipes(List<Ingredient> ingredients) async {
    try {
      if (ingredients.isEmpty) {
        return const Left(ValidationFailure('Please add at least one ingredient'));
      }

      final recipes = await localDataSource.getSampleRecipes(ingredients);
      return Right(recipes);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to load sample recipes'));
    }
  }

  @override
  Future<Either<Failure, bool>> testApiConnection() async {
    try {
      if (!(await networkInfo.isConnected)) {
        return const Right(false);
      }

      final isConnected = await remoteDataSource.testApiConnection();
      return Right(isConnected);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(_mapErrorToFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getCachedRecipes() async {
    try {
      final recipes = await localDataSource.getCachedRecipes();
      return Right(recipes);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to load cached recipes'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheRecipes(List<Recipe> recipes) async {
    try {
      if (recipes.isEmpty) {
        return const Left(ValidationFailure('No recipes to cache'));
      }

      await localDataSource.cacheRecipes(recipes);
      return const Right(null);
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace);
      return Left(CacheFailure('Failed to cache recipes'));
    }
  }

  Failure _mapErrorToFailure(dynamic error) {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('no internet') ||
        errorString.contains('network')) {
      return NetworkFailure(errorMessage);
    } else if (errorString.contains('401') ||
        errorString.contains('429') ||
        errorString.contains('400') ||
        errorString.contains('500') ||
        errorString.contains('api key') ||
        errorString.contains('server')) {
      return ServerFailure(errorMessage);
    } else {
      return ServerFailure(errorMessage);
    }
  }
}