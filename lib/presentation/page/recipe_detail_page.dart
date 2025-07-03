import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../core/constant/constants.dart';
import '../../domain/entity/recipe.dart';
import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_state.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<bool> _completedSteps = [];
  bool _isFavorite = false;
  int _currentServings = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _completedSteps.addAll(
      List.generate(widget.recipe.instructions.length, (index) => false),
    );
    _currentServings = widget.recipe.servings;
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() {
    // TODO: Load favorite status from persistent storage or database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildRecipeHeader(),
                _buildTabBar(),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppConstants.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: AutoSizeText(
          widget.recipe.title,
          style: AppConstants.titleStyle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryColor,
                AppConstants.secondaryColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image/recipe_pattern.png'),
                        repeat: ImageRepeat.repeat,
                        opacity: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      AutoSizeText(
                        widget.recipe.description,
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildHeaderInfo(
                            Icons.access_time,
                            widget.recipe.prepTimeFormatted,
                          ),
                          const SizedBox(width: 20),
                          _buildHeaderInfo(
                            Icons.people,
                            '$_currentServings servings',
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.recipe.difficultyColor,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                            child: AutoSizeText(
                              widget.recipe.difficulty,
                              style: AppConstants.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: _shareRecipe,
          icon: const Icon(Icons.share),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_ingredients',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy Ingredients'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy_recipe',
              child: Row(
                children: [
                  Icon(Icons.content_copy),
                  SizedBox(width: 8),
                  Text('Copy Recipe'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset_progress',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Reset Progress'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecipeHeader() {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        bool isUsingAI = true;
        if (state is RecipeLoaded) {
          isUsingAI = state.isUsingAI;
        } else if (state is ApiConnectionState) {
          isUsingAI = state.isConnected;
        }

        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingMedium),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUsingAI ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AutoSizeText(
                      isUsingAI ? 'AI Generated' : 'Sample Recipe',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentServings > 1 ? () => _adjustServings(-1) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppConstants.primaryColor,
                      ),
                      AutoSizeText(
                        '$_currentServings',
                        style: AppConstants.titleStyle.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: _currentServings < 12 ? () => _adjustServings(1) : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Prep Time', widget.recipe.prepTimeFormatted, Icons.schedule),
                  _buildStatCard('Difficulty', widget.recipe.difficulty, Icons.bar_chart),
                  _buildStatCard('Progress', '${_getCompletedStepsCount()}/${widget.recipe.instructions.length}', Icons.check_circle),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 20),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            style: AppConstants.captionStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          AutoSizeText(
            label,
            style: AppConstants.captionStyle.copyWith(
              fontSize: 10,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          color: AppConstants.primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondary,
        labelStyle: AppConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Ingredients'),
          Tab(text: 'Instructions'),
          Tab(text: 'Nutrition'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildIngredientsTab(),
          _buildInstructionsTab(),
          _buildNutritionTab(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        AutoSizeText(
          label,
          style: AppConstants.captionStyle.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsTab() {
    final servingRatio = _currentServings / widget.recipe.servings;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'Ingredients',
                style: AppConstants.titleStyle,
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _copyIngredients,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const AutoSizeText('Copy'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _createShoppingList,
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const AutoSizeText('Shop'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          if (_currentServings != widget.recipe.servings)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AutoSizeText(
                'Adjusted for $_currentServings servings',
                style: AppConstants.captionStyle.copyWith(
                  color: AppConstants.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.recipe.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = widget.recipe.ingredients[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppConstants.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AutoSizeText(
                          _adjustIngredientQuantity(ingredient, servingRatio),
                          style: AppConstants.bodyStyle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'Instructions',
                style: AppConstants.titleStyle,
              ),
              Row(
                children: [
                  AutoSizeText(
                    '${_getCompletedStepsCount()}/${widget.recipe.instructions.length}',
                    style: AppConstants.captionStyle.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircularProgressIndicator(
                    value: _getCompletedStepsCount() / widget.recipe.instructions.length,
                    strokeWidth: 3,
                    backgroundColor: AppConstants.backgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: ListView.builder(
              itemCount: widget.recipe.instructions.length,
              itemBuilder: (context, index) {
                final instruction = widget.recipe.instructions[index];
                final isCompleted = _completedSteps[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _toggleStep(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppConstants.secondaryColor
                                : AppConstants.backgroundColor,
                            shape: BoxShape.circle,
                            border: isCompleted
                                ? null
                                : Border.all(
                              color: AppConstants.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                                : AutoSizeText(
                              '${index + 1}',
                              style: AppConstants.captionStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppConstants.secondaryColor.withValues(alpha: 0.1)
                                : AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            border: Border.all(
                              color: isCompleted
                                  ? AppConstants.secondaryColor.withValues(alpha: 0.3)
                                  : AppConstants.primaryColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: AutoSizeText(
                            instruction,
                            style: AppConstants.bodyStyle.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? AppConstants.textSecondary
                                  : AppConstants.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Nutrition Information',
            style: AppConstants.titleStyle,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          AutoSizeText(
            'Per serving ($_currentServings servings)',
            style: AppConstants.captionStyle.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildNutritionCard('Calories', '~350', Icons.local_fire_department),
                _buildNutritionCard('Protein', '~25g', Icons.fitness_center),
                _buildNutritionCard('Carbs', '~45g', Icons.grain),
                _buildNutritionCard('Fat', '~15g', Icons.opacity),
                _buildNutritionCard('Fiber', '~8g', Icons.eco),
                _buildNutritionCard('Sodium', '~650mg', MdiIcons.shakerOutline),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AutoSizeText(
              'Nutritional values are approximate and may vary based on ingredients used.',
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 20),
          const SizedBox(height: 4),
          AutoSizeText(
            value,
            style: AppConstants.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          AutoSizeText(
            label,
            style: AppConstants.captionStyle.copyWith(
              fontSize: 11,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleStep(int index) {
    setState(() {
      _completedSteps[index] = !_completedSteps[index];
    });
    HapticFeedback.lightImpact();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoSizeText(
          _isFavorite ? 'Added to favorites!' : 'Removed from favorites!',
        ),
        backgroundColor: _isFavorite ? AppConstants.secondaryColor : AppConstants.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _adjustServings(int change) {
    setState(() {
      _currentServings += change;
    });
  }

  int _getCompletedStepsCount() {
    return _completedSteps.where((step) => step).length;
  }

  String _adjustIngredientQuantity(String ingredient, double ratio) {
    if (ratio == 1.0) return ingredient;

    final RegExp numberRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(\w+)');
    final match = numberRegex.firstMatch(ingredient);

    if (match != null) {
      final double originalQuantity = double.parse(match.group(1)!);
      final String unit = match.group(2)!;
      final double newQuantity = originalQuantity * ratio;

      return ingredient.replaceFirst(
        numberRegex,
        '${newQuantity.toStringAsFixed(1)} $unit',
      );
    }

    return ingredient;
  }

  void _copyIngredients() {
    final servingRatio = _currentServings / widget.recipe.servings;
    final ingredientsList = widget.recipe.ingredients
        .map((ingredient) => '• ${_adjustIngredientQuantity(ingredient, servingRatio)}')
        .join('\n');

    Clipboard.setData(ClipboardData(text: ingredientsList));
    _showSnackBar('Ingredients copied to clipboard!', AppConstants.secondaryColor);
  }

  void _createShoppingList() {
    _showSnackBar('Shopping list feature coming soon!', AppConstants.accentColor);
  }

  void _shareRecipe() {
    final servingRatio = _currentServings / widget.recipe.servings;
    final recipeText = '''
${widget.recipe.title}

${widget.recipe.description}

Prep Time: ${widget.recipe.prepTimeFormatted}
Servings: $_currentServings
Difficulty: ${widget.recipe.difficulty}

Ingredients:
${widget.recipe.ingredients.map((ingredient) => '• ${_adjustIngredientQuantity(ingredient, servingRatio)}').join('\n')}

Instructions:
${widget.recipe.instructions.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}

Generated by Smart Recipe Generator
''';

    Clipboard.setData(ClipboardData(text: recipeText));
    _showSnackBar('Recipe copied to clipboard for sharing!', AppConstants.primaryColor);
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'copy_ingredients':
        _copyIngredients();
        break;
      case 'copy_recipe':
        _shareRecipe();
        break;
      case 'reset_progress':
        setState(() {
          _completedSteps.fillRange(0, _completedSteps.length, false);
        });
        _showSnackBar('Progress reset!', AppConstants.textSecondary);
        break;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoSizeText(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}