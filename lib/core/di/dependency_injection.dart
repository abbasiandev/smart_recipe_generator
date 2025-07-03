
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_recipe_generator/core/di/service_locator.dart';
import 'package:smart_recipe_generator/core/network/network_info.dart';
import 'package:smart_recipe_generator/data/datasource/local_data_source.dart';
import 'package:smart_recipe_generator/data/datasource/remote_data_source.dart';

import '../../data/repository/ingredient_repository_impl.dart';
import '../../data/repository/recipe_repository_impl.dart';
import '../../domain/repository/ingredient_repository.dart';
import '../../domain/repository/recipe_repository.dart';
import '../../domain/usecase/add_ingredient_usecase.dart';
import '../../domain/usecase/generate_recipe_usecase.dart';
import '../../domain/usecase/get_sample_recipe_usecase.dart';
import '../../domain/usecase/get_saved_ingredient_usecase.dart';
import '../../domain/usecase/remove_ingredient_usecase.dart';
import '../../domain/usecase/test_api_connection_usecase.dart';
import '../../presentation/bloc/ingredient/ingredient_bloc.dart';
import '../../presentation/bloc/recipe/recipe_bloc.dart';

class DependencyInjection extends ServiceLocator {
  static final DependencyInjection _instance = DependencyInjection._internal();

  factory DependencyInjection() => _instance;

  DependencyInjection._internal();

  @override
  Future<void> init() async {
    await _initExternalDependencies();

    _initDataSources();
    _initRepositories();
    _initUseCases();
    _initBlocs();
  }

  Future<void> _initExternalDependencies() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    ServiceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

    final client = http.Client();
    ServiceLocator.registerSingleton<http.Client>(client);
  }

  void _initDataSources() {
    ServiceLocator.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(
        sharedPreferences: ServiceLocator.get<SharedPreferences>(),
      ),
    );

    ServiceLocator.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(
        client: ServiceLocator.get<http.Client>(),
      ),
    );
  }

  void _initRepositories() {
    ServiceLocator.registerLazySingleton<IngredientRepository>(
      () => IngredientRepositoryImpl(
        localDataSource: ServiceLocator.get<LocalDataSource>(),
      ),
    );

    ServiceLocator.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(),
    );

    ServiceLocator.registerLazySingleton<RecipeRepository>(
      () => RecipeRepositoryImpl(
        remoteDataSource: ServiceLocator.get<RemoteDataSource>(),
        localDataSource: ServiceLocator.get<LocalDataSource>(),
        networkInfo: ServiceLocator.get<NetworkInfo>()
      ),
    );
  }

  void _initUseCases() {
    ServiceLocator.registerLazySingleton(
          () => GetSavedIngredientsUseCase(ServiceLocator.get()),
    );
    ServiceLocator.registerLazySingleton(
          () => AddIngredientUseCase(ServiceLocator.get()),
    );
    ServiceLocator.registerLazySingleton(
          () => RemoveIngredientUseCase(ServiceLocator.get()),
    );

    ServiceLocator.registerLazySingleton(
          () => GenerateRecipesUseCase(ServiceLocator.get()),
    );
    ServiceLocator.registerLazySingleton(
          () => GetSampleRecipesUseCase(ServiceLocator.get()),
    );
    ServiceLocator.registerLazySingleton(
          () => TestApiConnectionUseCase(ServiceLocator.get()),
    );
  }

  void _initBlocs() {
    ServiceLocator.registerFactory(
      () => IngredientBloc(
        getSavedIngredientsUseCase: ServiceLocator.get(),
        addIngredientUseCase: ServiceLocator.get(),
        removeIngredientUseCase: ServiceLocator.get(),
      ),
    );

    ServiceLocator.registerFactory(
      () => RecipeBloc(
        generateRecipesUseCase: ServiceLocator.get(),
        getSampleRecipesUseCase: ServiceLocator.get(),
        testApiConnectionUseCase: ServiceLocator.get(),
      ),
    );
  }
}