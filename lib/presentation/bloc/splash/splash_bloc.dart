import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_recipe_generator/presentation/bloc/splash/splash_event.dart';
import 'package:smart_recipe_generator/presentation/bloc/splash/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onSplashAnimationCompleted);
  }

  Future<void> _onSplashStarted(
      SplashStarted event,
      Emitter<SplashState> emit,
      ) async {
    try {
      emit(SplashLoading());

      await _initializeApp();

      emit(SplashAnimating());

      await Future.delayed(const Duration(milliseconds: 6000));

      emit(SplashCompleted());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }

  Future<void> _onSplashAnimationCompleted(
      SplashAnimationCompleted event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashCompleted());
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.delayed(const Duration(milliseconds: 1500));
  }
}