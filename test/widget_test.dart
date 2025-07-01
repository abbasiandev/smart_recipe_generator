import 'package:flutter_test/flutter_test.dart';
import 'package:smart_recipe_generator/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRecipeGeneratorApp());

    expect(find.text('Smart Recipe Generator'), findsOneWidget);
    expect(find.text('Welcome to Smart Cooking!'), findsOneWidget);
    expect(find.text('Add Ingredients'), findsOneWidget);
  });

  testWidgets('Navigation to ingredients screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRecipeGeneratorApp());

    await tester.tap(find.text('Add Ingredients'));
    await tester.pumpAndSettle();

    expect(find.text('My Ingredients'), findsOneWidget);
  });
}