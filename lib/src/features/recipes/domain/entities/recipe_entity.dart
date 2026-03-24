import 'package:equatable/equatable.dart';

/// Represents a single recipe/meal from the API
class RecipeEntity extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final List<RecipeIngredient> ingredients;

  const RecipeEntity({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.ingredients = const [],
  });

  @override
  List<Object?> get props => [id, name, category, area, thumbnailUrl];
}

/// An ingredient with its measurement
class RecipeIngredient extends Equatable {
  final String name;
  final String measure;

  const RecipeIngredient({required this.name, required this.measure});

  @override
  List<Object?> get props => [name, measure];
}

/// A recipe category displayed on the recipes screen
class RecipeCategory {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String searchQuery;
  final List<String>? apiCategories;

  const RecipeCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.searchQuery,
    this.apiCategories,
  });
}
