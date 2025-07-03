import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String? quantity;
  final String? category;
  final DateTime addedAt;

  Ingredient({
    required this.name,
    this.quantity,
    this.category,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [name.toLowerCase(), category];

  @override
  String toString() {
    return quantity != null ? '$quantity $name' : name;
  }
}