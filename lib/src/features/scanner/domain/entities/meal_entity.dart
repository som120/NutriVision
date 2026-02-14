import 'package:equatable/equatable.dart';

/// Represents the macronutrient breakdown of a food item
class Macronutrients extends Equatable {
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;

  const Macronutrients({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
  });

  @override
  List<Object?> get props => [protein, carbohydrates, fat, fiber, sugar];
}

/// Represents a single micronutrient value
class MicronutrientValue extends Equatable {
  final double value;
  final String unit;

  const MicronutrientValue({required this.value, required this.unit});

  @override
  List<Object?> get props => [value, unit];
}

/// Represents the micronutrient breakdown
class Micronutrients extends Equatable {
  final MicronutrientValue? vitaminA;
  final MicronutrientValue? vitaminC;
  final MicronutrientValue? calcium;
  final MicronutrientValue? iron;
  final MicronutrientValue? potassium;
  final MicronutrientValue? sodium;

  const Micronutrients({
    this.vitaminA,
    this.vitaminC,
    this.calcium,
    this.iron,
    this.potassium,
    this.sodium,
  });

  @override
  List<Object?> get props => [
    vitaminA,
    vitaminC,
    calcium,
    iron,
    potassium,
    sodium,
  ];
}

/// Meal entity representing a scanned/logged food item
class MealEntity extends Equatable {
  final String id;
  final String userId;
  final String foodName;
  final String? imageUrl;
  final String servingSize;
  final double calories;
  final Macronutrients macronutrients;
  final Micronutrients? micronutrients;
  final double confidenceScore;
  final String foodCategory;
  final List<String> healthNotes;
  final MealType mealType;
  final DateTime loggedAt;

  const MealEntity({
    required this.id,
    required this.userId,
    required this.foodName,
    this.imageUrl,
    required this.servingSize,
    required this.calories,
    required this.macronutrients,
    this.micronutrients,
    this.confidenceScore = 0.0,
    this.foodCategory = 'Unknown',
    this.healthNotes = const [],
    this.mealType = MealType.snack,
    required this.loggedAt,
  });

  MealEntity copyWith({
    String? id,
    String? userId,
    String? foodName,
    String? imageUrl,
    String? servingSize,
    double? calories,
    Macronutrients? macronutrients,
    Micronutrients? micronutrients,
    double? confidenceScore,
    String? foodCategory,
    List<String>? healthNotes,
    MealType? mealType,
    DateTime? loggedAt,
  }) {
    return MealEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      imageUrl: imageUrl ?? this.imageUrl,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      macronutrients: macronutrients ?? this.macronutrients,
      micronutrients: micronutrients ?? this.micronutrients,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      foodCategory: foodCategory ?? this.foodCategory,
      healthNotes: healthNotes ?? this.healthNotes,
      mealType: mealType ?? this.mealType,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    foodName,
    imageUrl,
    servingSize,
    calories,
    macronutrients,
    micronutrients,
    confidenceScore,
    foodCategory,
    healthNotes,
    mealType,
    loggedAt,
  ];
}

/// Type of meal
enum MealType {
  breakfast('Breakfast', '🌅'),
  lunch('Lunch', '☀️'),
  dinner('Dinner', '🌙'),
  snack('Snack', '🍿');

  final String label;
  final String emoji;

  const MealType(this.label, this.emoji);
}
