import 'package:equatable/equatable.dart';

import '../../../../domain/entity/ingredient.dart';

abstract class IngredientEvent extends Equatable {
  const IngredientEvent();

  @override
  List<Object> get props => [];
}

class LoadIngredientsEvent extends IngredientEvent {}

class AddIngredientEvent extends IngredientEvent {
  final Ingredient ingredient;

  const AddIngredientEvent({required this.ingredient});

  @override
  List<Object> get props => [ingredient];
}

class RemoveIngredientEvent extends IngredientEvent {
  final Ingredient ingredient;

  const RemoveIngredientEvent({required this.ingredient});

  @override
  List<Object> get props => [ingredient];
}

class ClearAllIngredientsEvent extends IngredientEvent {}