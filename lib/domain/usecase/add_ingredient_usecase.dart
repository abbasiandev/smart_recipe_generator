import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../entity/ingredient.dart';
import '../repository/ingredient_repository.dart';

class AddIngredientUseCase implements UseCase<void, AddIngredientParams> {
  final IngredientRepository repository;

  AddIngredientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddIngredientParams params) async {
    return await repository.addIngredient(params.ingredient);
  }
}

class AddIngredientParams extends Equatable {
  final Ingredient ingredient;

  const AddIngredientParams({required this.ingredient});

  @override
  List<Object> get props => [ingredient];
}