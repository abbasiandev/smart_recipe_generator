class Ingredient {
  final String name;
  final String? quantity;
  final DateTime addedAt;

  Ingredient({
    required this.name,
    this.quantity,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;

  @override
  String toString() {
    return quantity != null ? '$quantity $name' : name;
  }
}