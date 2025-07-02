import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../service/ai_service.dart';
import '../util/constants.dart';
import '../util/error_handler.dart';
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
  String? _statusMessage;
  bool _isUsingAI = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _loadLastRecipes();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    if (kDebugMode) {
      print('DEBUG: Checking API connection on startup');
    }

    try {
      final isConnected = await AIService.testApiConnection();
      setState(() {
        _isUsingAI = isConnected;
      });

      if (kDebugMode) {
        print('DEBUG: API connection status: $isConnected');
      }

      if (!isConnected && _ingredients.isNotEmpty) {
        _showInfoSnackBar('AI service unavailable - will use sample recipes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: API connection check failed: $e');
      }
      setState(() {
        _isUsingAI = false;
      });
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ingredientsJson = prefs.getStringList('saved_ingredients') ?? [];

      setState(() {
        _ingredients = ingredientsJson
            .map((json) => Ingredient.fromJson(jsonDecode(json)))
            .toList();
      });

      if (kDebugMode) {
        print('DEBUG: Loaded ${_ingredients.length} ingredients');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load ingredients: $e');
      }
      _showErrorSnackBar('Failed to load saved ingredients');
    }
  }

  Future<void> _generateRecipes() async {
    if (_ingredients.isEmpty) {
      _showWarningSnackBar('Please add some ingredients first!');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _recipes.clear();
    });

    try {
      List<Recipe> recipes;
      String? errorMessage;

      try {
        recipes = await AIService.generateRecipes(_ingredients);

        setState(() {
          _isUsingAI = true;
        });

        if (kDebugMode) {
          print('SUCCESS: Generated ${recipes.length} recipes using AI service');
        }
      } catch (e, stackTrace) {
        ErrorHandler.handleError(e, stackTrace);

        errorMessage = ErrorHandler.getUserFriendlyMessage(e);

        setState(() {
          _isUsingAI = false;
        });

        if (kDebugMode) {
          print('AI Service failed, falling back to sample recipes. Error: $errorMessage');
        }

        recipes = await AIService.generateSampleRecipes(_ingredients);

        if (kDebugMode) {
          print('SUCCESS: Generated ${recipes.length} sample recipes as fallback');
        }
      }

      setState(() {
        _recipes = recipes;
        _isLoading = false;

        if (errorMessage != null) {
          _statusMessage = 'Using sample recipes: $errorMessage';
        } else {
          _statusMessage = null;
        }
      });

      await _saveRecipes(recipes);

      if (errorMessage != null) {
        _showInfoSnackBar('Generated sample recipes due to: $errorMessage');
      }

    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      final userMessage = ErrorHandler.getUserFriendlyMessage(e);

      if (kDebugMode) {
        print('COMPLETE FAILURE: Both AI service and sample recipes failed');
      }

      setState(() {
        _isLoading = false;
        _recipes = [];
        _statusMessage = 'Failed to generate recipes: $userMessage';
      });

      _showErrorSnackBar('Failed to generate recipes: $userMessage');
    }
  }

  Future<void> _saveRecipes(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = recipes
          .map((recipe) => jsonEncode(recipe.toJson()))
          .toList();
      await prefs.setStringList('last_generated_recipes', recipesJson);

      if (kDebugMode) {
        print('DEBUG: Saved ${recipes.length} recipes to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to save recipes: $e');
      }
    }
  }

  Future<void> _loadLastRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getStringList('last_generated_recipes') ?? [];

      if (recipesJson.isNotEmpty) {
        setState(() {
          _recipes = recipesJson
              .map((json) => Recipe.fromJson(jsonDecode(json)))
              .toList();
        });

        if (kDebugMode) {
          print('DEBUG: Loaded ${_recipes.length} saved recipes');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to load saved recipes: $e');
      }
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

      _checkApiConnection();
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoSizeText(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showWarningSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoSizeText(message),
          backgroundColor: AppConstants.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoSizeText(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      );
    }
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
        title: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                AppStrings.appName,
                style: AppConstants.titleStyle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _isUsingAI ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AutoSizeText(
                _isUsingAI ? 'AI' : 'DEMO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
          AutoSizeText(
            'Welcome to Smart Cooking!',
            style: AppConstants.headlineStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            AppStrings.tagline,
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          if (!_isUsingAI) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AutoSizeText(
                      'AI service unavailable - using sample recipes',
                      style: AppConstants.captionStyle.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AutoSizeText(
                AppStrings.myIngredients,
                style: AppConstants.titleStyle,
              ),
            ),
            TextButton.icon(
              onPressed: _navigateToIngredients,
              icon: const Icon(Icons.edit, size: 16),
              label: const AutoSizeText('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                AutoSizeText(
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
                  label: const AutoSizeText(AppStrings.addIngredients),
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
                AutoSizeText(
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
                        : Icon(_isUsingAI ? Icons.auto_awesome : Icons.restaurant_menu),
                    label: AutoSizeText(
                      _isLoading
                          ? 'Generating...'
                          : _isUsingAI
                          ? AppStrings.generateRecipe
                          : 'Generate Sample Recipes',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUsingAI ? AppConstants.accentColor : Colors.orange,
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
                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AutoSizeText(
                            _statusMessage!,
                            style: AppConstants.captionStyle.copyWith(
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

    if (_recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AutoSizeText(
                AppStrings.suggestedRecipes,
                style: AppConstants.titleStyle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isUsingAI ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AutoSizeText(
                  _isUsingAI ? 'AI Generated' : 'Sample Recipes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
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