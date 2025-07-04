import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/constants.dart';
import '../../core/util/snackbar_util.dart';
import '../../domain/entity/ingredient.dart';
import '../../domain/entity/recipe.dart';
import '../bloc/ingredient/ingredient_bloc.dart';
import '../bloc/ingredient/ingredient_event.dart';
import '../bloc/ingredient/ingredient_state.dart';
import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';
import '../widget/ingredient_chip.dart';
import '../widget/loading_animation.dart';
import '../widget/recipe_card.dart';
import 'ingredients_input_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<IngredientBloc>().add(LoadIngredientsEvent());
    context.read<RecipeBloc>().add(TestApiConnectionEvent());
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
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        bool isUsingAI = true;
        if (state is RecipeLoaded) {
          isUsingAI = state.isUsingAI;
        } else if (state is ApiConnectionState) {
          isUsingAI = state.isConnected;
        }

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
                    color: isUsingAI ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AutoSizeText(
                    isUsingAI ? 'AI' : 'DEMO',
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
      },
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        bool isUsingAI = true;
        if (state is RecipeLoaded) {
          isUsingAI = state.isUsingAI;
        } else if (state is ApiConnectionState) {
          isUsingAI = state.isConnected;
        }

        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.secondaryColor.withValues(alpha: 0.1),
                AppConstants.primaryColor.withValues(alpha: 0.05),
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
              if (!isUsingAI) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
      },
    );
  }

  Widget _buildIngredientsSection() {
    return BlocConsumer<IngredientBloc, IngredientState>(
      listener: (context, state) {
        if (state is IngredientError) {
          SnackbarUtil.showError(context, state.message);
        } else if (state is IngredientValidationError) {
          SnackbarUtil.showWarning(context, state.message);
        }
      },
      builder: (context, state) {
        List<Ingredient> ingredients = [];
        bool isLoading = false;

        if (state is IngredientLoading) {
          isLoading = true;
        } else if (state is IngredientLoaded) {
          ingredients = state.ingredients;
        } else if (state is IngredientOperationSuccess) {
          ingredients = state.ingredients;
        }

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
                  onPressed: () => _navigateToIngredients(ingredients),
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (ingredients.isEmpty)
              _buildEmptyIngredientsCard()
            else
              _buildIngredientsCard(ingredients),
          ],
        );
      },
    );
  }

  Widget _buildEmptyIngredientsCard() {
    return Container(
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
            color: AppConstants.textSecondary.withValues(alpha: 0.5),
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
            onPressed: () => _navigateToIngredients([]),
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
    );
  }

  Widget _buildIngredientsCard(List<Ingredient> ingredients) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, recipeState) {
        bool isUsingAI = true;
        bool isGenerating = false;

        if (recipeState is RecipeLoading) {
          isGenerating = true;
        } else if (recipeState is RecipeLoaded) {
          isUsingAI = recipeState.isUsingAI;
        } else if (recipeState is ApiConnectionState) {
          isUsingAI = recipeState.isConnected;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Available ingredients (${ingredients.length})',
                style: AppConstants.captionStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                children: ingredients.map((ingredient) {
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
                  onPressed: isGenerating
                      ? null
                      : () => _generateRecipes(ingredients, isUsingAI),
                  icon: isGenerating
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(isUsingAI ? Icons.auto_awesome : Icons.restaurant_menu),
                  label: AutoSizeText(
                    isGenerating
                        ? 'Generating...'
                        : isUsingAI
                        ? AppStrings.generateRecipe
                        : 'Generate Sample Recipes',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUsingAI ? AppConstants.accentColor : Colors.orange,
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
        );
      },
    );
  }

  Widget _buildRecipesSection() {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeError) {
          SnackbarUtil.showError(context, state.message);
        } else if (state is RecipeLoaded && state.statusMessage != null) {
          SnackbarUtil.showInfo(context, state.statusMessage!);
        }
      },
      builder: (context, state) {
        if (state is RecipeLoading) {
          return const SizedBox(
            height: 300,
            child: LoadingAnimation(),
          );
        }

        if (state is RecipeLoaded && state.recipes.isNotEmpty) {
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
                        color: state.isUsingAI ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AutoSizeText(
                        state.isUsingAI ? 'AI Generated' : 'Sample Recipes',
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
                itemCount: state.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = state.recipes[index];
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

        return const SizedBox.shrink();
      },
    );
  }

  void _generateRecipes(List<Ingredient> ingredients, bool isUsingAI) {
    if (ingredients.isEmpty) {
      SnackbarUtil.showWarning(context, 'Please add some ingredients first!');
      return;
    }

    if (isUsingAI) {
      context.read<RecipeBloc>().add(GenerateRecipesEvent(ingredients: ingredients));
    } else {
      context.read<RecipeBloc>().add(GetSampleRecipesEvent(ingredients: ingredients));
    }
  }

  Future<void> _navigateToIngredients(List<Ingredient> currentIngredients) async {
    final ingredientBloc = context.read<IngredientBloc>();

    final result = await Navigator.of(context).push<List<Ingredient>>(
      MaterialPageRoute(
        builder: (ctx) => IngredientsInputPage(
          initialIngredients: currentIngredients,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      ingredientBloc.add(LoadIngredientsEvent());
    }
  }


  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }
}