abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAnimating extends SplashState {}

class SplashCompleted extends SplashState {}

class SplashError extends SplashState {
  final String message;

  SplashError(this.message);
}