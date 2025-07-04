import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/usecase/generate_recipe_usecase.dart';
import '../../../domain/usecase/get_sample_recipe_usecase.dart';
import '../../../domain/usecase/test_api_connection_usecase.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GenerateRecipesUseCase generateRecipesUseCase;
  final GetSampleRecipesUseCase getSampleRecipesUseCase;
  final TestApiConnectionUseCase testApiConnectionUseCase;

  RecipeBloc({
    required this.generateRecipesUseCase,
    required this.getSampleRecipesUseCase,
    required this.testApiConnectionUseCase,
  }) : super(RecipeInitial()) {
    on<GenerateRecipesEvent>(_onGenerateRecipes);
    on<GetSampleRecipesEvent>(_onGetSampleRecipes);
    on<TestApiConnectionEvent>(_onTestApiConnection);
  }

  Future<void> _onGenerateRecipes(
      GenerateRecipesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    emit(RecipeLoading());
    final result = await generateRecipesUseCase(
      GenerateRecipesParams(ingredients: event.ingredients),
    );

    // Fixed: Properly await nested async operations
    await result.fold(
          (failure) async {
        final sampleResult = await getSampleRecipesUseCase(
          GetSampleRecipesParams(ingredients: event.ingredients),
        );
        sampleResult.fold(
              (sampleFailure) => emit(RecipeError(message: failure.message)),
              (sampleRecipes) => emit(RecipeLoaded(
            recipes: sampleRecipes,
            isUsingAI: false,
            statusMessage: 'Using sample recipes: ${failure.message}',
          )),
        );
      },
          (recipes) async {
        emit(RecipeLoaded(
          recipes: recipes,
          isUsingAI: true,
        ));
      },
    );
  }

  Future<void> _onGetSampleRecipes(
      GetSampleRecipesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    emit(RecipeLoading());
    final result = await getSampleRecipesUseCase(
      GetSampleRecipesParams(ingredients: event.ingredients),
    );

    // Fixed: Make fold async and await it
    await result.fold(
          (failure) async => emit(RecipeError(message: failure.message)),
          (recipes) async => emit(RecipeLoaded(
        recipes: recipes,
        isUsingAI: false,
      )),
    );
  }

  Future<void> _onTestApiConnection(
      TestApiConnectionEvent event,
      Emitter<RecipeState> emit,
      ) async {
    final result = await testApiConnectionUseCase(NoParams());

    // Fixed: Make fold async and await it
    await result.fold(
          (failure) async => emit(ApiConnectionState(isConnected: false)),
          (isConnected) async => emit(ApiConnectionState(isConnected: isConnected)),
    );
  }
}