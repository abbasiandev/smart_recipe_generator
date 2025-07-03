import 'package:flutter/material.dart';

import '../../core/constant/constants.dart';
import '../../domain/entity/ingredient.dart';

class IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onDeleted;
  final bool showDelete;

  const IngredientChip({
    super.key,
    required this.ingredient,
    this.onDeleted,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(
          ingredient.toString(),
          style: AppConstants.captionStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        deleteIcon: showDelete
            ? const Icon(
          Icons.close,
          size: 18,
          color: Colors.white,
        )
            : null,
        onDeleted: showDelete ? onDeleted : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}