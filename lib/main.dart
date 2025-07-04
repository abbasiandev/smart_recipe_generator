import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constant/constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/di/service_locator.dart';
import 'presentation/bloc/ingredient/ingredient_bloc.dart';
import 'presentation/bloc/recipe/recipe_bloc.dart';
import 'presentation/bloc/splash/splash_bloc.dart';
import 'presentation/page/splash_page.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('No .env file found, using sample recipes');
  }

  final di = DependencyInjection();
  await di.init();

  runApp(const SmartRecipeGeneratorApp());
}

class SmartRecipeGeneratorApp extends StatelessWidget {
  const SmartRecipeGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc(),
        ),
        BlocProvider<IngredientBloc>(
          create: (context) => sl<IngredientBloc>(),
        ),
        BlocProvider<RecipeBloc>(
          create: (context) => sl<RecipeBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              borderSide: const BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}