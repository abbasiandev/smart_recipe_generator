import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/recipe.dart';
import '../util/constants.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<bool> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _completedSteps.addAll(
      List.generate(widget.recipe.instructions.length, (index) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.secondaryColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        AutoSizeText(
                          widget.recipe.description,
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildHeaderInfo(
                              Icons.access_time,
                              widget.recipe.prepTimeFormatted,
                            ),
                            const SizedBox(width: 20),
                            _buildHeaderInfo(
                              Icons.people,
                              '${widget.recipe.servings}',
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
              ),
            ),
            actions: [
              IconButton(
                onPressed: _shareRecipe,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                      color: AppConstants.primaryColor,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppConstants.textSecondary,
                    labelStyle: AppConstants.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Ingredients'),
                      Tab(text: 'Instructions'),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIngredientsTab(),
                      _buildInstructionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white70,
        ),
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
              TextButton.icon(
                onPressed: _copyIngredients,
                icon: const Icon(Icons.copy, size: 16),
                label: const AutoSizeText('Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: ListView.builder(
              itemCount: widget.recipe.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = widget.recipe.ingredients[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    border: Border.all(
                      color: AppConstants.backgroundColor,
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
                          ingredient,
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
              AutoSizeText(
                '${_completedSteps.where((step) => step).length}/${widget.recipe.instructions.length}',
                style: AppConstants.captionStyle.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
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
                        onTap: () {
                          setState(() {
                            _completedSteps[index] = !_completedSteps[index];
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
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
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppConstants.secondaryColor.withOpacity(0.1)
                                : AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: isCompleted
                                  ? AppConstants.secondaryColor.withOpacity(0.3)
                                  : AppConstants.backgroundColor,
                              width: 1,
                            ),
                          ),
                          child: AutoSizeText(
                            instruction,
                            style: AppConstants.bodyStyle.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
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

  void _copyIngredients() {
    final ingredientsList = widget.recipe.ingredients
        .map((ingredient) => '• $ingredient')
        .join('\n');

    Clipboard.setData(ClipboardData(text: ingredientsList));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const AutoSizeText('Ingredients copied to clipboard!'),
        backgroundColor: AppConstants.secondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  void _shareRecipe() {
    final recipeText = '''
${widget.recipe.title}

${widget.recipe.description}

Prep Time: ${widget.recipe.prepTimeFormatted}
Servings: ${widget.recipe.servings}
Difficulty: ${widget.recipe.difficulty}

Ingredients:
${widget.recipe.ingredients.map((ingredient) => '• $ingredient').join('\n')}

Instructions:
${widget.recipe.instructions.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}

Generated by Smart Recipe Generator
''';

    Clipboard.setData(ClipboardData(text: recipeText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const AutoSizeText('Recipe copied to clipboard for sharing!'),
        backgroundColor: AppConstants.primaryColor,
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
    super.dispose();
  }
}