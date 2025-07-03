import 'package:equatable/equatable.dart';

import '../../../../domain/entity/ingredient.dart';

abstract class IngredientState extends Equatable {
  const IngredientState();

  @override
  List<Object> get props => [];
}

class IngredientInitial extends IngredientState {}

class IngredientLoading extends IngredientState {}

class IngredientLoaded extends IngredientState {
  final List<Ingredient> ingredients;

  const IngredientLoaded({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}

class IngredientError extends IngredientState {
  final String message;

  const IngredientError({required this.message});

  @override
  List<Object> get props => [message];
}

class IngredientOperationSuccess extends IngredientState {
  final String message;
  final List<Ingredient> ingredients;

  const IngredientOperationSuccess({
    required this.message,
    required this.ingredients,
  });

  @override
  List<Object> get props => [message, ingredients];
}