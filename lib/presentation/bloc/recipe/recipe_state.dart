import 'package:equatable/equatable.dart';

import '../../../domain/entity/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final bool isUsingAI;
  final String? statusMessage;

  const RecipeLoaded({
    required this.recipes,
    required this.isUsingAI,
    this.statusMessage,
  });

  @override
  List<Object> get props => [recipes, isUsingAI];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError({required this.message});

  @override
  List<Object> get props => [message];
}

class ApiConnectionState extends RecipeState {
  final bool isConnected;

  const ApiConnectionState({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}