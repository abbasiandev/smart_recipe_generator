import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../util/error_handler.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const int _timeoutSeconds = 30;

  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  static Future<bool> testApiConnection() async {
    try {
      if (_apiKey.isEmpty) {
        if (kDebugMode) {
          print('DEBUG: API key is empty');
        }
        return false;
      }

      if (kDebugMode) {
        print('DEBUG: Testing API connection with key: ${_apiKey.substring(0, 10)}...');
      }

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
              'role': 'user',
              'content': 'Hello',
            }
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) {
        print('DEBUG: API test response status: ${response.statusCode}');
        print('DEBUG: API test response body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('DEBUG: API test failed: $e');
        ErrorHandler.handleError(e, stackTrace);
      }
      return false;
    }
  }

  static Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients) async {
    if (kDebugMode) {
      print('DEBUG: Starting recipe generation for ${ingredients.length} ingredients');
    }

    if (_apiKey.isEmpty) {
      final error = Exception('OpenAI API key not found. Please add it to your .env file');
      if (kDebugMode) {
        print('DEBUG: API key is empty');
      }
      throw error;
    }

    if (kDebugMode) {
      print('DEBUG: Using API key: ${_apiKey.substring(0, 10)}...');
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
      "difficulty": "Easy",
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

IMPORTANT: Respond ONLY with valid JSON, no additional text.
''';

    try {
      if (kDebugMode) {
        print('DEBUG: Sending request to OpenAI API');
      }

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
              'content': 'You are a helpful chef assistant that creates recipes based on available ingredients. Always respond with valid JSON only, no additional text or formatting.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) {
        print('DEBUG: Response status code: ${response.statusCode}');
        print('DEBUG: Response headers: ${response.headers}');
        print('DEBUG: Response body length: ${response.body.length}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('DEBUG: Parsed response data keys: ${data.keys}');
        }

        if (!data.containsKey('choices') || data['choices'].isEmpty) {
          throw Exception('Invalid API response: missing choices');
        }

        final content = data['choices'][0]['message']['content'];

        if (kDebugMode) {
          print('DEBUG: AI response content: $content');
        }

        String cleanContent = content.trim();

        final jsonStart = cleanContent.indexOf('{');
        final jsonEnd = cleanContent.lastIndexOf('}');

        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          cleanContent = cleanContent.substring(jsonStart, jsonEnd + 1);
        }

        final recipesData = jsonDecode(cleanContent);

        if (!recipesData.containsKey('recipes')) {
          throw Exception('Invalid recipe format: missing recipes array');
        }

        final List<Recipe> recipes = [];

        for (final recipeJson in recipesData['recipes']) {
          try {
            recipes.add(Recipe.fromJson(recipeJson));
          } catch (e) {
            if (kDebugMode) {
              print('DEBUG: Failed to parse recipe: $recipeJson');
              print('DEBUG: Parse error: $e');
            }
          }
        }

        if (recipes.isEmpty) {
          throw Exception('No valid recipes could be parsed from the response');
        }

        if (kDebugMode) {
          print('DEBUG: Successfully generated ${recipes.length} recipes');
        }

        return recipes;
      } else {
        final errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        if (kDebugMode) {
          print('DEBUG: API error: $errorMessage');
        }

        if (response.statusCode == 401) {
          throw Exception('Invalid API key. Please check your OpenAI API key.');
        } else if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded. Please wait and try again.');
        } else if (response.statusCode == 400) {
          throw Exception('Bad request. Please check your input.');
        } else {
          throw Exception('Failed to generate recipes: $errorMessage');
        }
      }
    } on SocketException catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Network error. Please check your connection.');
    } on FormatException catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Invalid response format from AI service.');
    } on Exception catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(e, stackTrace);
      throw Exception('Unexpected error generating recipes: ${e.toString()}');
    }
  }

  static Future<List<Recipe>> generateSampleRecipes(List<Ingredient> ingredients) async {
    if (kDebugMode) {
      print('DEBUG: Generating sample recipes');
    }

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