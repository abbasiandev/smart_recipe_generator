import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/constants.dart';
import '../../domain/entity/ingredient.dart';
import '../bloc/ingredient/ingredient_bloc.dart';
import '../bloc/ingredient/ingredient_event.dart';
import '../bloc/ingredient/ingredient_state.dart';
import '../widget/ingredient_chip.dart';

class IngredientsInputPage extends StatefulWidget {
  final List<Ingredient> initialIngredients;

  const IngredientsInputPage({
    super.key,
    this.initialIngredients = const [],
  });

  @override
  State<IngredientsInputPage> createState() => _IngredientsInputPageState();
}

class _IngredientsInputPageState extends State<IngredientsInputPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _suggestions = [
    'Chicken breast', 'Tomatoes', 'Onion', 'Garlic', 'Rice', 'Pasta',
    'Bell peppers', 'Carrots', 'Potatoes', 'Spinach', 'Cheese', 'Eggs',
    'Mushrooms', 'Broccoli', 'Ground beef', 'Salmon', 'Lemon', 'Herbs',
    'Olive oil', 'Salt', 'Black pepper', 'Parsley', 'Basil', 'Oregano'
  ];

  @override
  void initState() {
    super.initState();
    context.read<IngredientBloc>().add(LoadIngredientsEvent());
  }

  void _addIngredient(String name) {
    if (name.trim().isEmpty) return;

    final ingredient = Ingredient(name: name.trim());
    context.read<IngredientBloc>().add(AddIngredientEvent(ingredient: ingredient));
    _controller.clear();
  }

  void _removeIngredient(Ingredient ingredient) {
    context.read<IngredientBloc>().add(RemoveIngredientEvent(ingredient: ingredient));
  }

  List<Ingredient> _getCurrentIngredients() {
    final state = context.read<IngredientBloc>().state;
    if (state is IngredientLoaded) {
      return state.ingredients;
    } else if (state is IngredientOperationSuccess) {
      return state.ingredients;
    } else if (state is IngredientValidationError) {
      return state.ingredients;
    } else if (state is IngredientError) {
      return state.ingredients;
    }
    return [];
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
          BlocBuilder<IngredientBloc, IngredientState>(
            builder: (context, state) {
              final hasIngredients = (state is IngredientLoaded && state.ingredients.isNotEmpty) ||
                  (state is IngredientOperationSuccess && state.ingredients.isNotEmpty) ||
                  (state is IngredientValidationError && state.ingredients.isNotEmpty) ||
                  (state is IngredientError && state.ingredients.isNotEmpty);

              return TextButton(
                onPressed: hasIngredients
                    ? () {
                  List<Ingredient> ingredients = [];
                  if (state is IngredientLoaded) {
                    ingredients = state.ingredients;
                  } else if (state is IngredientOperationSuccess) {
                    ingredients = state.ingredients;
                  } else if (state is IngredientValidationError) {
                    ingredients = state.ingredients;
                  } else if (state is IngredientError) {
                    ingredients = state.ingredients;
                  }
                  Navigator.pop(context, ingredients);
                }
                    : null,
                child: AutoSizeText(
                  'Done',
                  style: AppConstants.bodyStyle.copyWith(
                    color: hasIngredients ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<IngredientBloc, IngredientState>(
            listenWhen: (previous, current) {
              return current is IngredientOperationSuccess;
            },
            listener: (context, state) {
              if (state is IngredientOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 1),
                  ),
                );
                Future.delayed(const Duration(milliseconds: 1100), () {
                  if (mounted) {
                    context.read<IngredientBloc>().add(LoadIngredientsEvent());
                  }
                });
              }
            },
          ),
          BlocListener<IngredientBloc, IngredientState>(
            listenWhen: (previous, current) {
              return current is IngredientError || current is IngredientValidationError;
            },
            listener: (context, state) {
              if (state is IngredientError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is IngredientValidationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<IngredientBloc, IngredientState>(
          builder: (context, state) {
            List<Ingredient> ingredients = [];
            bool isLoading = false;

            if (state is IngredientLoading) {
              isLoading = true;
              ingredients = _getCurrentIngredients();
            } else if (state is IngredientLoaded) {
              ingredients = state.ingredients;
            } else if (state is IngredientOperationSuccess) {
              ingredients = state.ingredients;
            } else if (state is IngredientValidationError) {
              ingredients = state.ingredients;
            } else if (state is IngredientError) {
              ingredients = state.ingredients;
            }

            return Column(
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
                            onPressed: isLoading ? null : () => _addIngredient(_controller.text),
                            icon: isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Icon(Icons.send),
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
                        onSubmitted: isLoading ? null : _addIngredient,
                        textCapitalization: TextCapitalization.words,
                        enabled: !isLoading,
                      ),
                      if (ingredients.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.paddingMedium),
                        AutoSizeText(
                          'Your Ingredients (${ingredients.length})',
                          style: AppConstants.titleStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Wrap(
                          children: ingredients.map((ingredient) {
                            return IngredientChip(
                              ingredient: ingredient,
                              onDeleted: isLoading ? null : () => _removeIngredient(ingredient),
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
                              final isAdded = ingredients.any(
                                    (ingredient) => ingredient.name.toLowerCase() ==
                                    suggestion.toLowerCase(),
                              );

                              return Material(
                                color: isAdded
                                    ? AppConstants.secondaryColor.withValues(alpha: 0.2)
                                    : AppConstants.cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium,
                                ),
                                child: InkWell(
                                  onTap: (isAdded || isLoading) ? null : () => _addIngredient(suggestion),
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
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}