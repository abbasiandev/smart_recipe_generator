import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/constant/constants.dart';
import '../../domain/entity/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final int index;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: Material(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              elevation: 2,
              shadowColor: Colors.black12,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  recipe.title,
                                  style: AppConstants.titleStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                AutoSizeText(
                                  recipe.description,
                                  style: AppConstants.captionStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: recipe.difficultyColor,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                            child: AutoSizeText(
                              recipe.difficulty,
                              style: AppConstants.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.access_time,
                            recipe.prepTimeFormatted,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.people,
                            '${recipe.servings} servings',
                          ),
                        ],
                      ),
                      if (recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.paddingSmall),
                        Wrap(
                          spacing: 6,
                          children: recipe.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusSmall,
                                ),
                              ),
                              child: AutoSizeText(
                                tag,
                                style: AppConstants.captionStyle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.textSecondary,
        ),
        const SizedBox(width: 4),
        AutoSizeText(
          label,
          style: AppConstants.captionStyle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}