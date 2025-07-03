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
  }

  Future<void> _onLoadIngredients(
      LoadIngredientsEvent event,
      Emitter<IngredientState> emit,
      ) async {
    emit(IngredientLoading());

    final result = await getSavedIngredientsUseCase(NoParams());

    result.fold(
          (failure) => emit(IngredientError(message: failure.message)),
          (ingredients) => emit(IngredientLoaded(ingredients: ingredients)),
    );
  }

  Future<void> _onAddIngredient(
      AddIngredientEvent event,
      Emitter<IngredientState> emit,
      ) async {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(IngredientLoading());

      final result = await addIngredientUseCase(
        AddIngredientParams(ingredient: event.ingredient),
      );

      result.fold(
            (failure) => emit(IngredientError(message: failure.message)),
            (_) {
          final updatedIngredients = <Ingredient>[
            ...currentState.ingredients,
            event.ingredient,
          ];
          emit(IngredientOperationSuccess(
            message: 'Ingredient added successfully',
            ingredients: updatedIngredients,
          ));
        },
      );
    }
  }

  Future<void> _onRemoveIngredient(
      RemoveIngredientEvent event,
      Emitter<IngredientState> emit,
      ) async {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(IngredientLoading());

      final result = await removeIngredientUseCase(
        RemoveIngredientParams(ingredient: event.ingredient),
      );

      result.fold(
            (failure) => emit(IngredientError(message: failure.message)),
            (_) {
          final updatedIngredients = currentState.ingredients
              .where((ingredient) => ingredient != event.ingredient)
              .toList();
          emit(IngredientOperationSuccess(
            message: 'Ingredient removed successfully',
            ingredients: updatedIngredients,
          ));
        },
      );
    }
  }
}