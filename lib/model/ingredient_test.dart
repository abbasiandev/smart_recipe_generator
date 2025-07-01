import 'package:flutter_test/flutter_test.dart';
import 'package:smart_recipe_generator/model/ingredient.dart';

void main() {
  group('Ingredient Model Tests', () {
    test('Ingredient creation works correctly', () {
      final ingredient = Ingredient(name: 'Tomato', quantity: '2 pieces');

      expect(ingredient.name, 'Tomato');
      expect(ingredient.quantity, '2 pieces');
      expect(ingredient.toString(), '2 pieces Tomato');
    });

    test('Ingredient without quantity works correctly', () {
      final ingredient = Ingredient(name: 'Salt');

      expect(ingredient.name, 'Salt');
      expect(ingredient.quantity, null);
      expect(ingredient.toString(), 'Salt');
    });

    test('Ingredient equality works correctly', () {
      final ingredient1 = Ingredient(name: 'Tomato');
      final ingredient2 = Ingredient(name: 'tomato');
      final ingredient3 = Ingredient(name: 'Onion');

      expect(ingredient1 == ingredient2, true);
      expect(ingredient1 == ingredient3, false);
    });

    test('Ingredient JSON serialization works correctly', () {
      final ingredient = Ingredient(name: 'Tomato', quantity: '2 pieces');
      final json = ingredient.toJson();
      final reconstructed = Ingredient.fromJson(json);

      expect(reconstructed.name, ingredient.name);
      expect(reconstructed.quantity, ingredient.quantity);
    });
  });
}