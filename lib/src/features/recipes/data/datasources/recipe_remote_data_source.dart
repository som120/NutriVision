import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/recipe_model.dart';

/// Remote data source for fetching recipes from TheMealDB API
class RecipeRemoteDataSource {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  RecipeRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  /// Search meals by name
  Future<List<RecipeModel>> searchMeals(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search.php?s=$query'),
      );
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to search meals');
      }
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) return [];
      return meals
          .map((m) => RecipeModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to search meals: $e');
    }
  }

  /// Filter meals by category (returns partial info — no instructions)
  Future<List<RecipeModel>> filterByCategory(String category) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/filter.php?c=$category'),
      );
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to filter meals');
      }
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) return [];
      return meals
          .map((m) => RecipeModel.fromFilterJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to filter meals: $e');
    }
  }

  /// Lookup full meal details by ID
  Future<RecipeModel?> getMealById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to get meal details');
      }
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;
      return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get meal details: $e');
    }
  }

  /// Get a random meal
  Future<RecipeModel?> getRandomMeal() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/random.php'),
      );
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to get random meal');
      }
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;
      return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get random meal: $e');
    }
  }

  /// Filter meals by main ingredient
  Future<List<RecipeModel>> filterByIngredient(String ingredient) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/filter.php?i=$ingredient'),
      );
      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to filter by ingredient');
      }
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) return [];
      return meals
          .map((m) => RecipeModel.fromFilterJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to filter by ingredient: $e');
    }
  }
}
