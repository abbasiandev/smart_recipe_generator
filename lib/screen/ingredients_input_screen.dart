import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ingredient.dart';
import '../util/constants.dart';
import '../widget/ingredient_chip.dart';

class IngredientsInputScreen extends StatefulWidget {
  final List<Ingredient> initialIngredients;

  const IngredientsInputScreen({
    super.key,
    this.initialIngredients = const [],
  });

  @override
  State<IngredientsInputScreen> createState() => _IngredientsInputScreenState();
}

class _IngredientsInputScreenState extends State<IngredientsInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Ingredient> _ingredients = [];
  final List<String> _suggestions = [
    'Chicken breast', 'Tomatoes', 'Onion', 'Garlic', 'Rice', 'Pasta',
    'Bell peppers', 'Carrots', 'Potatoes', 'Spinach', 'Cheese', 'Eggs',
    'Mushrooms', 'Broccoli', 'Ground beef', 'Salmon', 'Lemon', 'Herbs'
  ];

  @override
  void initState() {
    super.initState();
    _ingredients.addAll(widget.initialIngredients);
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = prefs.getStringList('saved_ingredients') ?? [];

    setState(() {
      _ingredients.clear();
      _ingredients.addAll(widget.initialIngredients);

      for (final json in ingredientsJson) {
        final ingredient = Ingredient.fromJson(jsonDecode(json));
        if (!_ingredients.contains(ingredient)) {
          _ingredients.add(ingredient);
        }
      }
    });
  }

  Future<void> _saveIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = _ingredients
        .map((ingredient) => jsonEncode(ingredient.toJson()))
        .toList();
    await prefs.setStringList('saved_ingredients', ingredientsJson);
  }

  void _addIngredient(String name) {
    if (name.trim().isEmpty) return;

    final ingredient = Ingredient(name: name.trim());
    if (!_ingredients.contains(ingredient)) {
      setState(() {
        _ingredients.add(ingredient);
      });
      _saveIngredients();
    }
    _controller.clear();
  }

  void _removeIngredient(Ingredient ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
    _saveIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: AutoSizeText(
          AppStrings.myIngredients,
          style: AppConstants.titleStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _ingredients.isNotEmpty
                ? () => Navigator.pop(context, _ingredients)
                : null,
            child: AutoSizeText(
              'Done',
              style: AppConstants.bodyStyle.copyWith(
                color: _ingredients.isNotEmpty ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: AppStrings.ingredientHint,
                    hintStyle: AppConstants.captionStyle,
                    prefixIcon: const Icon(Icons.add),
                    suffixIcon: IconButton(
                      onPressed: () => _addIngredient(_controller.text),
                      icon: const Icon(Icons.send),
                    ),
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
                  onSubmitted: _addIngredient,
                  textCapitalization: TextCapitalization.words,
                ),
                if (_ingredients.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingMedium),
                  AutoSizeText(
                    'Your Ingredients (${_ingredients.length})',
                    style: AppConstants.titleStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Wrap(
                    children: _ingredients.map((ingredient) {
                      return IngredientChip(
                        ingredient: ingredient,
                        onDeleted: () => _removeIngredient(ingredient),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Popular Ingredients',
                    style: AppConstants.titleStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final isAdded = _ingredients.any(
                              (ingredient) => ingredient.name.toLowerCase() ==
                              suggestion.toLowerCase(),
                        );

                        return Material(
                          color: isAdded
                              ? AppConstants.secondaryColor.withOpacity(0.2)
                              : AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          child: InkWell(
                            onTap: isAdded ? null : () => _addIngredient(suggestion),
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppConstants.paddingSmall,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isAdded ? Icons.check_circle : Icons.add_circle_outline,
                                    color: isAdded
                                        ? AppConstants.secondaryColor
                                        : AppConstants.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AutoSizeText(
                                      suggestion,
                                      style: AppConstants.captionStyle.copyWith(
                                        fontWeight: isAdded
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isAdded
                                            ? AppConstants.secondaryColor
                                            : AppConstants.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}