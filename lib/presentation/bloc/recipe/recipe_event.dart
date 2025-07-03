import 'package:equatable/equatable.dart';

import '../../../domain/entity/ingredient.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class GenerateRecipesEvent extends RecipeEvent {
  final List<Ingredient> ingredients;

  const GenerateRecipesEvent({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}

class GetSampleRecipesEvent extends RecipeEvent {
  final List<Ingredient> ingredients;

  const GetSampleRecipesEvent({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}

class TestApiConnectionEvent extends RecipeEvent {}

class LoadCachedRecipesEvent extends RecipeEvent {}