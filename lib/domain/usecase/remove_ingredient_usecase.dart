import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../entity/ingredient.dart';
import '../repository/ingredient_repository.dart';

class RemoveIngredientUseCase implements UseCase<void, RemoveIngredientParams> {
  final IngredientRepository repository;

  RemoveIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveIngredientParams params) async {
    return await repository.removeIngredient(params.ingredient);
  }
}

class RemoveIngredientParams extends Equatable {
  final Ingredient ingredient;

  const RemoveIngredientParams({required this.ingredient});

  @override
  List<Object> get props => [ingredient];
}