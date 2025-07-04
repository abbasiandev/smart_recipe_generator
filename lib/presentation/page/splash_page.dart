import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/constants.dart';
import '../../core/util/snackbar_util.dart';
import '../bloc/splash/splash_bloc.dart';
import '../bloc/splash/splash_event.dart';
import '../bloc/splash/splash_state.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    context.read<SplashBloc>().add(SplashStarted());
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashAnimating) {
            _startAnimations();
          } else if (state is SplashCompleted) {
            _navigateToHome();
          } else if (state is SplashError) {
            SnackbarUtil.showError(context, state.message);
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            return AnimatedBuilder(
              animation: Listenable.merge([
                _logoController,
                _textController,
                _backgroundController,
              ]),
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          Colors.green.shade200,
                          Colors.green.shade400,
                          _backgroundAnimation.value,
                        )!,
                        Color.lerp(
                          Colors.green.shade300,
                          Colors.green.shade600,
                          _backgroundAnimation.value,
                        )!,
                        Color.lerp(
                          Colors.green.shade400,
                          Colors.green.shade800,
                          _backgroundAnimation.value,
                        )!,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _logoController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _logoScaleAnimation.value,
                                  child: Transform.rotate(
                                    angle: _logoRotationAnimation.value * 0.5,
                                    child: Opacity(
                                      opacity: _logoOpacityAnimation.value,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Icon(
                                            Icons.restaurant_menu,
                                            size: 80,
                                            color: Colors.green.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: _textSlideAnimation,
                                child: Opacity(
                                  opacity: _textOpacityAnimation.value,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.appName,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Cook Smart, Eat Well',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _backgroundController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _backgroundAnimation.value,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withValues(alpha: 0.8),
                                        ),
                                        strokeWidth: 2,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _getLoadingText(state),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getLoadingText(SplashState state) {
    if (state is SplashLoading) {
      return 'Initializing...';
    } else if (state is SplashAnimating) {
      return 'Loading...';
    } else if (state is SplashError) {
      return 'Error occurred';
    }
    return 'Welcome';
  }
}