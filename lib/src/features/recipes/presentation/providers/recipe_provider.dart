import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/recipe_remote_data_source.dart';
import '../../domain/entities/recipe_entity.dart';

// ─── Data Source Provider ────────────────────────────────────
final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSource();
});

// ─── Curated Categories ──────────────────────────────────────
/// All recipe categories shown on the recipes page.
/// Each maps to a search query or API category/ingredient filter.
final recipeCategoriesProvider = Provider<List<RecipeCategory>>((ref) {
  return const [
    RecipeCategory(
      id: 'grab_and_go',
      title: 'Grab & Go',
      subtitle: 'Quick, easy meals on the run',
      emoji: '🥪',
      searchQuery: 'sandwich',
    ),
    RecipeCategory(
      id: 'glp1_lunches_dinners',
      title: 'GLP-1 Friendly Lunches & Dinners',
      subtitle: 'Lean protein & veggies',
      emoji: '🥗',
      searchQuery: 'grilled',
    ),
    RecipeCategory(
      id: 'glp1_breakfasts',
      title: 'GLP-1 Friendly Breakfasts',
      subtitle: 'High protein, low sugar starts',
      emoji: '🍳',
      searchQuery: 'omelette',
    ),
    RecipeCategory(
      id: 'glp1_meals',
      title: 'GLP-1 Friendly Meals',
      subtitle: 'Balanced, nutrient-dense options',
      emoji: '🫛',
      searchQuery: 'salad',
    ),
    RecipeCategory(
      id: 'high_protein',
      title: 'High Protein',
      subtitle: 'Protein-packed recipes',
      emoji: '💪',
      searchQuery: '',
      apiCategories: ['Chicken', 'Beef'],
    ),
    RecipeCategory(
      id: 'high_protein_breakfast',
      title: 'High Protein Breakfast',
      subtitle: 'Fuel your morning right',
      emoji: '🥚',
      searchQuery: 'egg',
    ),
    RecipeCategory(
      id: 'high_protein_lunch_dinner',
      title: 'High Protein Lunches & Dinners',
      subtitle: 'Main courses loaded with protein',
      emoji: '🍗',
      searchQuery: '',
      apiCategories: ['Seafood', 'Chicken'],
    ),
    RecipeCategory(
      id: 'pre_workout',
      title: 'Pre Workout',
      subtitle: 'Energize before training',
      emoji: '⚡',
      searchQuery: 'oats',
    ),
    RecipeCategory(
      id: 'post_workout',
      title: 'Post Workout',
      subtitle: 'Recover & rebuild',
      emoji: '🏋️',
      searchQuery: 'chicken',
    ),
    RecipeCategory(
      id: 'under_300',
      title: 'Under 300 Calories',
      subtitle: 'Light & satisfying',
      emoji: '🥒',
      searchQuery: '',
      apiCategories: ['Vegetarian', 'Side'],
    ),
    RecipeCategory(
      id: 'under_500',
      title: 'Under 500 Calories',
      subtitle: 'Balanced & filling',
      emoji: '🍲',
      searchQuery: '',
      apiCategories: ['Starter', 'Miscellaneous'],
    ),
  ];
});

// ─── Category Recipes Provider (family) ──────────────────────
/// Fetches recipes for a given category.
/// Uses search endpoint or category filter depending on the category config.
final categoryRecipesProvider =
    FutureProvider.family<List<RecipeEntity>, RecipeCategory>((
  ref,
  category,
) async {
  final dataSource = ref.read(recipeRemoteDataSourceProvider);

  // If we have API categories, use filter endpoint
  if (category.apiCategories != null && category.apiCategories!.isNotEmpty) {
    final allRecipes = <RecipeEntity>[];
    for (final cat in category.apiCategories!) {
      final recipes = await dataSource.filterByCategory(cat);
      allRecipes.addAll(recipes);
    }
    // Shuffle for variety and deduplicate
    allRecipes.shuffle();
    final seen = <String>{};
    return allRecipes.where((r) => seen.add(r.id)).toList();
  }

  // Otherwise use search endpoint
  if (category.searchQuery.isNotEmpty) {
    return dataSource.searchMeals(category.searchQuery);
  }

  return [];
});

// ─── Meal Detail Provider ────────────────────────────────────
final recipeDetailProvider =
    FutureProvider.family<RecipeEntity?, String>((ref, id) async {
  final dataSource = ref.read(recipeRemoteDataSourceProvider);
  return dataSource.getMealById(id);
});
