import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/meal_entity.dart';

/// Meal model for Firebase serialization/deserialization
class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.userId,
    required super.foodName,
    super.imageUrl,
    required super.servingSize,
    required super.calories,
    required super.macronutrients,
    super.micronutrients,
    super.confidenceScore,
    super.foodCategory,
    super.healthNotes,
    super.mealType,
    required super.loggedAt,
  });

  /// Create from Firebase document
  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final macroData = data['macronutrients'] as Map<String, dynamic>? ?? {};

    return MealModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      foodName: data['foodName'] as String? ?? 'Unknown',
      imageUrl: data['imageUrl'] as String?,
      servingSize: data['servingSize'] as String? ?? '',
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      macronutrients: Macronutrients(
        protein: (macroData['protein'] as num?)?.toDouble() ?? 0,
        carbohydrates: (macroData['carbohydrates'] as num?)?.toDouble() ?? 0,
        fat: (macroData['fat'] as num?)?.toDouble() ?? 0,
        fiber: (macroData['fiber'] as num?)?.toDouble() ?? 0,
        sugar: (macroData['sugar'] as num?)?.toDouble() ?? 0,
      ),
      micronutrients: _parseMicronutrients(
        data['micronutrients'] as Map<String, dynamic>?,
      ),
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0,
      foodCategory: data['foodCategory'] as String? ?? 'Unknown',
      healthNotes: List<String>.from(data['healthNotes'] ?? []),
      mealType: MealType.values.firstWhere(
        (t) => t.name == (data['mealType'] as String?),
        orElse: () => MealType.snack,
      ),
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from AI analysis JSON response
  factory MealModel.fromAIResponse({
    required String userId,
    required Map<String, dynamic> json,
    String? imageUrl,
    MealType mealType = MealType.snack,
  }) {
    final macroData = json['macronutrients'] as Map<String, dynamic>? ?? {};
    final microData = json['micronutrients'] as Map<String, dynamic>? ?? {};

    return MealModel(
      id: '', // Will be assigned by Firestore
      userId: userId,
      foodName: json['food_name'] as String? ?? 'Unknown Food',
      imageUrl: imageUrl,
      servingSize: json['serving_size'] as String? ?? 'Unknown',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      macronutrients: Macronutrients(
        protein:
            ((macroData['protein'] as Map<String, dynamic>?)?['value'] as num?)
                ?.toDouble() ??
            0,
        carbohydrates:
            ((macroData['carbohydrates'] as Map<String, dynamic>?)?['value']
                    as num?)
                ?.toDouble() ??
            0,
        fat:
            ((macroData['fat'] as Map<String, dynamic>?)?['value'] as num?)
                ?.toDouble() ??
            0,
        fiber:
            ((macroData['fiber'] as Map<String, dynamic>?)?['value'] as num?)
                ?.toDouble() ??
            0,
        sugar:
            ((macroData['sugar'] as Map<String, dynamic>?)?['value'] as num?)
                ?.toDouble() ??
            0,
      ),
      micronutrients: Micronutrients(
        vitaminA: _parseMicronutrientValue(
          microData['vitamin_a'] as Map<String, dynamic>?,
        ),
        vitaminC: _parseMicronutrientValue(
          microData['vitamin_c'] as Map<String, dynamic>?,
        ),
        calcium: _parseMicronutrientValue(
          microData['calcium'] as Map<String, dynamic>?,
        ),
        iron: _parseMicronutrientValue(
          microData['iron'] as Map<String, dynamic>?,
        ),
        potassium: _parseMicronutrientValue(
          microData['potassium'] as Map<String, dynamic>?,
        ),
        sodium: _parseMicronutrientValue(
          microData['sodium'] as Map<String, dynamic>?,
        ),
      ),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0,
      foodCategory: json['food_category'] as String? ?? 'Unknown',
      healthNotes: List<String>.from(json['health_notes'] ?? []),
      mealType: mealType,
      loggedAt: DateTime.now(),
    );
  }

  /// Create from MealEntity
  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      userId: entity.userId,
      foodName: entity.foodName,
      imageUrl: entity.imageUrl,
      servingSize: entity.servingSize,
      calories: entity.calories,
      macronutrients: entity.macronutrients,
      micronutrients: entity.micronutrients,
      confidenceScore: entity.confidenceScore,
      foodCategory: entity.foodCategory,
      healthNotes: entity.healthNotes,
      mealType: entity.mealType,
      loggedAt: entity.loggedAt,
    );
  }

  /// Convert to Firebase document map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'foodName': foodName,
      'imageUrl': imageUrl,
      'servingSize': servingSize,
      'calories': calories,
      'macronutrients': {
        'protein': macronutrients.protein,
        'carbohydrates': macronutrients.carbohydrates,
        'fat': macronutrients.fat,
        'fiber': macronutrients.fiber,
        'sugar': macronutrients.sugar,
      },
      'micronutrients': _micronutrientsToMap(),
      'confidenceScore': confidenceScore,
      'foodCategory': foodCategory,
      'healthNotes': healthNotes,
      'mealType': mealType.name,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }

  Map<String, dynamic>? _micronutrientsToMap() {
    if (micronutrients == null) return null;
    return {
      'vitamin_a': _micronutrientValueToMap(micronutrients!.vitaminA),
      'vitamin_c': _micronutrientValueToMap(micronutrients!.vitaminC),
      'calcium': _micronutrientValueToMap(micronutrients!.calcium),
      'iron': _micronutrientValueToMap(micronutrients!.iron),
      'potassium': _micronutrientValueToMap(micronutrients!.potassium),
      'sodium': _micronutrientValueToMap(micronutrients!.sodium),
    };
  }

  static Map<String, dynamic>? _micronutrientValueToMap(
    MicronutrientValue? value,
  ) {
    if (value == null) return null;
    return {'value': value.value, 'unit': value.unit};
  }

  static MicronutrientValue? _parseMicronutrientValue(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return null;
    return MicronutrientValue(
      value: (data['value'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? '',
    );
  }

  static Micronutrients? _parseMicronutrients(Map<String, dynamic>? data) {
    if (data == null) return null;
    return Micronutrients(
      vitaminA: _parseMicronutrientValue(
        data['vitamin_a'] as Map<String, dynamic>?,
      ),
      vitaminC: _parseMicronutrientValue(
        data['vitamin_c'] as Map<String, dynamic>?,
      ),
      calcium: _parseMicronutrientValue(
        data['calcium'] as Map<String, dynamic>?,
      ),
      iron: _parseMicronutrientValue(data['iron'] as Map<String, dynamic>?),
      potassium: _parseMicronutrientValue(
        data['potassium'] as Map<String, dynamic>?,
      ),
      sodium: _parseMicronutrientValue(data['sodium'] as Map<String, dynamic>?),
    );
  }
}
