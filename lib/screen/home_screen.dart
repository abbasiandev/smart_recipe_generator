import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../service/ai_service.dart';
import '../util/constants.dart';
import '../widget/ingredient_chip.dart';
import '../widget/loading_animation.dart';
import '../widget/recipe_card.dart';
import 'ingredients_input_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = prefs.getStringList('saved_ingredients') ?? [];

    setState(() {
      _ingredients = ingredientsJson
          .map((json) => Ingredient.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _generateRecipes() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add some ingredients first!'),
          backgroundColor: AppConstants.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recipes.clear();
    });

    try {
      List<Recipe> recipes;
      try {
        recipes = await AIService.generateRecipes(_ingredients);
      } catch (e) {
        // Fallback to sample recipes if AI service fails
        recipes = await AIService.generateSampleRecipes(_ingredients);
      }

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });

      await _saveRecipes(recipes);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = recipes
        .map((recipe) => jsonEncode(recipe.toJson()))
        .toList();
    await prefs.setStringList('last_generated_recipes', recipesJson);
  }

  Future<void> _loadLastRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList('last_generated_recipes') ?? [];

    if (recipesJson.isNotEmpty) {
      setState(() {
        _recipes = recipesJson
            .map((json) => Recipe.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  Future<void> _navigateToIngredients() async {
    final result = await Navigator.push<List<Ingredient>>(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientsInputScreen(
          initialIngredients: _ingredients,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _ingredients = result;
      });
    }
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildIngredientsSection(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildRecipesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: AppConstants.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppStrings.appName,
          style: AppConstants.titleStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.secondaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Smart Cooking!',
            style: AppConstants.headlineStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tagline,
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.myIngredients,
              style: AppConstants.titleStyle,
            ),
            TextButton.icon(
              onPressed: _navigateToIngredients,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        if (_ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: AppConstants.backgroundColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.kitchen,
                  size: 48,
                  color: AppConstants.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.noIngredients,
                  style: AppConstants.bodyStyle.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _navigateToIngredients,
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addIngredients),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available ingredients (${_ingredients.length})',
                  style: AppConstants.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: _ingredients.map((ingredient) {
                    return IngredientChip(
                      ingredient: ingredient,
                      showDelete: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateRecipes,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isLoading ? 'Generating...' : AppStrings.generateRecipe),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipesSection() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: LoadingAnimation(),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.error,
              style: AppConstants.titleStyle.copyWith(
                color: Colors.red.shade700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppConstants.captionStyle.copyWith(
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.suggestedRecipes,
          style: AppConstants.titleStyle,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recipes.length,
          itemBuilder: (context, index) {
            final recipe = _recipes[index];
            return RecipeCard(
              recipe: recipe,
              index: index,
              onTap: () => _navigateToRecipeDetail(recipe),
            );
          },
        ),
      ],
    );
  }
}