class Food {
  final String id;
  final String name;
  final double caloriesPer100g;

  Food({required this.id, required this.name, required this.caloriesPer100g});

  Map<String, dynamic> toMap() {
    return {'name': name, 'caloriesPer100g': caloriesPer100g};
  }

  factory Food.fromMap(String id, Map<String, dynamic> map) {
    return Food(
      id: id,
      name: map['name'],
      caloriesPer100g: (map['caloriesPer100g'] as num).toDouble(),
    );
  }
}
