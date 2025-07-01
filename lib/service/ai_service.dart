import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/ingredient.dart';
import '../model/recipe.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  static Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please add it to your .env file');
    }

    final ingredientList = ingredients.map((e) => e.toString()).join(', ');

    final prompt = '''
Generate 2-3 creative and practical recipes using these ingredients: $ingredientList

For each recipe, provide a JSON response with this exact structure:
{
  "recipes": [
    {
      "title": "Recipe Name",
      "description": "Brief appetizing description (1-2 sentences)",
      "ingredients": ["ingredient 1", "ingredient 2", "etc"],
      "instructions": ["step 1", "step 2", "etc"],
      "prepTimeMinutes": 30,
      "servings": 4,
      "difficulty": "Easy|Medium|Hard",
      "tags": ["tag1", "tag2", "tag3"]
    }
  ]
}

Guidelines:
- Use as many provided ingredients as possible
- Include common pantry items if needed (salt, pepper, oil, etc.)
- Make instructions clear and numbered
- Ensure recipes are realistic and achievable
- Add relevant tags (cuisine type, meal type, dietary info)
- Vary difficulty levels across recipes
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful chef assistant that creates recipes based on available ingredients. Always respond with valid JSON.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        final recipesData = jsonDecode(content);
        final List<Recipe> recipes = [];

        for (final recipeJson in recipesData['recipes']) {
          recipes.add(Recipe.fromJson(recipeJson));
        }

        return recipes;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenAI API key.');
      } else {
        throw Exception('Failed to generate recipes: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response format from AI service.');
    } catch (e) {
      throw Exception('Error generating recipes: ${e.toString()}');
    }
  }

  static Future<List<Recipe>> generateSampleRecipes(List<Ingredient> ingredients) async {
    await Future.delayed(const Duration(seconds: 2));

    final ingredientNames = ingredients.map((e) => e.name.toLowerCase()).toList();

    final sampleRecipes = <Recipe>[
      Recipe(
        title: 'Quick Stir Fry',
        description: 'A colorful and nutritious stir fry perfect for any meal.',
        ingredients: [
          ...ingredientNames.take(3),
          'soy sauce',
          'garlic',
          'ginger',
          'vegetable oil'
        ],
        instructions: [
          'Heat oil in a large pan or wok over medium-high heat',
          'Add minced garlic and ginger, stir for 30 seconds',
          'Add your main ingredients and stir fry for 3-4 minutes',
          'Add soy sauce and toss everything together',
          'Cook for another 2-3 minutes until everything is heated through',
          'Serve hot over rice or noodles'
        ],
        prepTimeMinutes: 15,
        servings: 2,
        difficulty: 'Easy',
        tags: ['Quick', 'Healthy', 'Asian', 'Stir Fry'],
      ),
      Recipe(
        title: 'Hearty Soup',
        description: 'A warming and comforting soup made with your fresh ingredients.',
        ingredients: [
          ...ingredientNames.take(4),
          'vegetable broth',
          'onion',
          'salt',
          'pepper',
          'herbs'
        ],
        instructions: [
          'Chop all vegetables into bite-sized pieces',
          'Heat a large pot over medium heat and add a bit of oil',
          'Sauté onions until translucent, about 3-4 minutes',
          'Add remaining vegetables and cook for 5 minutes',
          'Pour in vegetable broth and bring to a boil',
          'Reduce heat and simmer for 20-25 minutes',
          'Season with salt, pepper, and herbs to taste',
          'Serve hot with crusty bread'
        ],
        prepTimeMinutes: 35,
        servings: 4,
        difficulty: 'Easy',
        tags: ['Comfort Food', 'Healthy', 'Soup', 'Vegetarian'],
      ),
    ];

    return sampleRecipes;
  }
}