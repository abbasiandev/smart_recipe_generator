import 'dart:ui';

class Recipe {
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int servings;
  final String difficulty;
  final List<String> tags;
  final DateTime generatedAt;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.tags,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'tags': tags,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      prepTimeMinutes: json['prepTimeMinutes'],
      servings: json['servings'],
      difficulty: json['difficulty'],
      tags: List<String>.from(json['tags']),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  String get prepTimeFormatted {
    if (prepTimeMinutes < 60) {
      return '${prepTimeMinutes}m';
    } else {
      final hours = prepTimeMinutes ~/ 60;
      final minutes = prepTimeMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }
}