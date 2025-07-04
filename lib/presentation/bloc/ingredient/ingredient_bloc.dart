import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../domain/entity/ingredient.dart';
import '../../../domain/usecase/add_ingredient_usecase.dart';
import '../../../domain/usecase/get_saved_ingredient_usecase.dart';
import '../../../domain/usecase/remove_ingredient_usecase.dart';
import 'ingredient_event.dart';
import 'ingredient_state.dart';

class IngredientBloc extends Bloc<IngredientEvent, IngredientState> {
  final GetSavedIngredientsUseCase getSavedIngredientsUseCase;
  final AddIngredientUseCase addIngredientUseCase;
  final RemoveIngredientUseCase removeIngredientUseCase;

  IngredientBloc({
    required this.getSavedIngredientsUseCase,
    required this.addIngredientUseCase,
    required this.removeIngredientUseCase,
  }) : super(IngredientInitial()) {
    on<LoadIngredientsEvent>(_onLoadIngredients);
    on<AddIngredientEvent>(_onAddIngredient);
    on<RemoveIngredientEvent>(_onRemoveIngredient);
    on<ClearAllIngredientsEvent>(_onClearAllIngredients);
  }

  List<Ingredient> _getCurrentIngredients() {
    if (state is IngredientLoaded) {
      return (state as IngredientLoaded).ingredients;
    } else if (state is IngredientOperationSuccess) {
      return (state as IngredientOperationSuccess).ingredients;
    } else if (state is IngredientValidationError) {
      return (state as IngredientValidationError).ingredients;
    } else if (state is IngredientError) {
      return (state as IngredientError).ingredients;
    }
    return [];
  }

  Future<void> _onLoadIngredients(
      LoadIngredientsEvent event,
      Emitter<IngredientState> emit,
      ) async {
    emit(IngredientLoading());

    final result = await getSavedIngredientsUseCase(NoParams());

    result.fold(
          (failure) => emit(IngredientError(
        message: failure.message,
        ingredients: [],
      )),
          (ingredients) => emit(IngredientLoaded(ingredients: ingredients)),
    );
  }

  Future<void> _onAddIngredient(
      AddIngredientEvent event,
      Emitter<IngredientState> emit,
      ) async {
    List<Ingredient> currentIngredients = _getCurrentIngredients();

    final ingredientName = event.ingredient.name.trim();
    if (ingredientName.isEmpty) {
      emit(IngredientValidationError(
        message: 'Ingredient name cannot be empty',
        ingredients: currentIngredients,
      ));
      return;
    }

    final isDuplicate = currentIngredients.any((ingredient) =>
    ingredient.name.toLowerCase() == ingredientName.toLowerCase());

    if (isDuplicate) {
      emit(IngredientValidationError(
        message: '$ingredientName already exists',
        ingredients: currentIngredients,
      ));
      return;
    }

    emit(IngredientLoading());

    final result = await addIngredientUseCase(
      AddIngredientParams(ingredient: event.ingredient),
    );

    result.fold(
          (failure) {
        emit(IngredientError(
          message: failure.message,
          ingredients: currentIngredients,
        ));
      },
          (success) {
        final updatedIngredients = [...currentIngredients, event.ingredient];
        emit(IngredientLoaded(ingredients: updatedIngredients));
      },
    );
  }

  Future<void> _onRemoveIngredient(
      RemoveIngredientEvent event,
      Emitter<IngredientState> emit,
      ) async {
    List<Ingredient> currentIngredients = _getCurrentIngredients();

    if (currentIngredients.isEmpty) {
      emit(IngredientValidationError(
        message: 'No ingredients to remove',
        ingredients: currentIngredients,
      ));
      return;
    }

    final ingredientExists = currentIngredients.any(
            (ingredient) => ingredient.name.toLowerCase() == event.ingredient.name.toLowerCase()
    );

    if (!ingredientExists) {
      emit(IngredientValidationError(
        message: '${event.ingredient.name} not found',
        ingredients: currentIngredients,
      ));
      return;
    }

    emit(IngredientLoading());

    final result = await removeIngredientUseCase(
      RemoveIngredientParams(ingredient: event.ingredient),
    );

    result.fold(
          (failure) {
        emit(IngredientError(
          message: failure.message,
          ingredients: currentIngredients,
        ));
      },
          (success) {
        final updatedIngredients = currentIngredients
            .where((ingredient) => ingredient != event.ingredient)
            .toList();
        emit(IngredientLoaded(ingredients: updatedIngredients));
      },
    );
  }

  Future<void> _onClearAllIngredients(
      ClearAllIngredientsEvent event,
      Emitter<IngredientState> emit,
      ) async {
    emit(IngredientLoaded(ingredients: []));
  }
}