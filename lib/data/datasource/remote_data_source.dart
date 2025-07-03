import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/entity/ingredient.dart';
import '../../domain/entity/recipe.dart';

abstract class RemoteDataSource {
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients);
  Future<bool> testApiConnection();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const int _timeoutSeconds = 30;

  RemoteDataSourceImpl({required this.client});

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  @override
  Future<bool> testApiConnection() async {
    if (_apiKey.isEmpty) return false;

    try {
      final response = await client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [{'role': 'user', 'content': 'Hello'}],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('API test failed: $e');
      return false;
    }
  }

  @override
  Future<List<Recipe>> generateRecipes(List<Ingredient> ingredients) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found');
    }

    final ingredientList = ingredients.map((e) => e.name).join(', ');
    final prompt = _buildPrompt(ingredientList);

    try {
      final response = await client.post(
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
              'content': 'You are a helpful chef assistant that creates recipes based on available ingredients. Always respond with valid JSON only.'
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseRecipeResponse(content);
      } else {
        throw _handleHttpError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Network error occurred');
    } on FormatException {
      throw Exception('Invalid response format');
    }
  }

  String _buildPrompt(String ingredientList) {
    return '''
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
  }

  List<Recipe> _parseRecipeResponse(String content) {
    try {
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
        recipes.add(Recipe.fromJson(recipeJson));
      }

      if (recipes.isEmpty) {
        throw Exception('No valid recipes could be parsed');
      }

      return recipes;
    } catch (e) {
      throw Exception('Failed to parse recipes: ${e.toString()}');
    }
  }

  Exception _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return Exception('Invalid API key');
      case 429:
        return Exception('Rate limit exceeded');
      case 400:
        return Exception('Bad request');
      default:
        return Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}