import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static TextStyle get headlineStyle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 16,
    color: textPrimary,
  );

  static TextStyle get captionStyle => GoogleFonts.inter(
    fontSize: 14,
    color: textSecondary,
  );

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
}

class AppStrings {
  static const String appName = 'Smart Recipe Generator';
  static const String tagline = 'Turn your ingredients into delicious meals';
  static const String addIngredients = 'Add Ingredients';
  static const String generateRecipe = 'Generate Recipe';
  static const String myIngredients = 'My Ingredients';
  static const String suggestedRecipes = 'Suggested Recipes';
  static const String loading = 'Cooking up something delicious...';
  static const String error = 'Oops! Something went wrong';
  static const String noIngredients = 'Add some ingredients to get started!';
  static const String ingredientHint = 'e.g., tomatoes, chicken, rice';
}