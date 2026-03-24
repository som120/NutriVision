import '../../domain/entities/recipe_entity.dart';

/// Recipe model for API serialization/deserialization
class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.name,
    super.category,
    super.area,
    super.instructions,
    super.thumbnailUrl,
    super.youtubeUrl,
    super.ingredients,
  });

  /// Create from full TheMealDB JSON (search or lookup endpoints)
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <RecipeIngredient>[];

    // TheMealDB returns ingredients as strIngredient1..20 and strMeasure1..20
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(
          RecipeIngredient(
            name: ingredient.trim(),
            measure: measure?.trim() ?? '',
          ),
        );
      }
    }

    return RecipeModel(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      thumbnailUrl: json['strMealThumb'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }

  /// Create from filter endpoint JSON (partial — no instructions/ingredients)
  factory RecipeModel.fromFilterJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String?,
    );
  }
}
