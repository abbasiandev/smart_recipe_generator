import 'package:get_it/get_it.dart';

abstract class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  static GetIt get instance => _instance;

  static T get<T extends Object>() => _instance<T>();

  Future<void> init();

  static void reset() => _instance.reset();

  static void registerSingleton<T extends Object>(
      T instance, {
        String? instanceName,
      }) {
    _instance.registerSingleton<T>(instance, instanceName: instanceName);
  }

  static void registerLazySingleton<T extends Object>(
      T Function() factoryFunc, {
        String? instanceName,
      }) {
    _instance.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
  }

  static void registerFactory<T extends Object>(
      T Function() factoryFunc, {
        String? instanceName,
      }) {
    _instance.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }

  static void registerSingletonAsync<T extends Object>(
      Future<T> Function() factoryFunc, {
        String? instanceName,
      }) {
    _instance.registerSingletonAsync<T>(factoryFunc, instanceName: instanceName);
  }

  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _instance.isRegistered<T>(instanceName: instanceName);
  }

  static Future<void> unregister<T extends Object>({String? instanceName}) async {
    await _instance.unregister<T>(instanceName: instanceName);
  }
}

T sl<T extends Object>() => ServiceLocator.get<T>();