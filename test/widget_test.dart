import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple math test', () {
    expect(2 + 2, equals(4));
  });

  test('String test', () {
    expect('hello'.toUpperCase(), equals('HELLO'));
  });
}