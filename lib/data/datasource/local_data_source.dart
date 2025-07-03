import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/ingredient.dart';
import '../../domain/entity/recipe.dart';

abstract class LocalDataSource {
  Future<List<Ingredient>> getSavedIngredients();
  Future<void> saveIngredients(List<Ingredient> ingredients);
  Future<List<Recipe>> getCachedRecipes();
  Future<void> cacheRecipes(List<Recipe> recipes);
  Future<List<Recipe>> getSampleRecipes(List<Ingredient> ingredients);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _ingredientsKey = 'saved_ingredients';
  static const String _recipesKey = 'last_generated_recipes';

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Ingredient>> getSavedIngredients() async {
    final ingredientsJson = sharedPreferences.getStringList(_ingredientsKey) ?? [];
    return ingredientsJson
        .map((json) => Ingredient.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> saveIngredients(List<Ingredient> ingredients) async {
    final ingredientsJson = ingredients
        .map((ingredient) => jsonEncode(ingredient.toJson()))
        .toList();
    await sharedPreferences.setStringList(_ingredientsKey, ingredientsJson);
  }

  @override
  Future<List<Recipe>> getCachedRecipes() async {
    final recipesJson = sharedPreferences.getStringList(_recipesKey) ?? [];
    return recipesJson
        .map((json) => Recipe.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> cacheRecipes(List<Recipe> recipes) async {
    final recipesJson = recipes
        .map((recipe) => jsonEncode(recipe.toJson()))
        .toList();
    await sharedPreferences.setStringList(_recipesKey, recipesJson);
  }

  @override
  Future<List<Recipe>> getSampleRecipes(List<Ingredient> ingredients) async {
    await Future.delayed(const Duration(seconds: 2));

    final ingredientNames = ingredients.map((e) => e.name.toLowerCase()).toList();

    return [
      Recipe(
        title: 'Quick Stir Fry',
        description: 'A colorful and nutritious stir fry perfect for any meal.',
        ingredients: [
          ...ingredientNames.take(3),
          'soy sauce',
          'garlic',
          'ginger',
          'vegetable oil'
        ],
        instructions: [
          'Heat oil in a large pan or wok over medium-high heat',
          'Add minced garlic and ginger, stir for 30 seconds',
          'Add your main ingredients and stir fry for 3-4 minutes',
          'Add soy sauce and toss everything together',
          'Cook for another 2-3 minutes until everything is heated through',
          'Serve hot over rice or noodles'
        ],
        prepTimeMinutes: 15,
        servings: 2,
        difficulty: 'Easy',
        tags: ['Quick', 'Healthy', 'Asian', 'Stir Fry'],
      ),
      Recipe(
        title: 'Hearty Soup',
        description: 'A warming and comforting soup made with your fresh ingredients.',
        ingredients: [
          ...ingredientNames.take(4),
          'vegetable broth',
          'onion',
          'salt',
          'pepper',
          'herbs'
        ],
        instructions: [
          'Chop all vegetables into bite-sized pieces',
          'Heat a large pot over medium heat and add a bit of oil',
          'Sauté onions until translucent, about 3-4 minutes',
          'Add remaining vegetables and cook for 5 minutes',
          'Pour in vegetable broth and bring to a boil',
          'Reduce heat and simmer for 20-25 minutes',
          'Season with salt, pepper, and herbs to taste',
          'Serve hot with crusty bread'
        ],
        prepTimeMinutes: 35,
        servings: 4,
        difficulty: 'Easy',
        tags: ['Comfort Food', 'Healthy', 'Soup', 'Vegetarian'],
      ),
    ];
  }
}