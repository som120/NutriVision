import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';

/// Data source for Open Food Facts API
/// Docs: https://wiki.openfoodfacts.org/API
class OpenFoodFactsDataSource {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  final http.Client _client;

  OpenFoodFactsDataSource({http.Client? client})
      : _client = client ?? http.Client();

  /// Lookup a product by barcode
  /// Returns null if product is not found
  Future<OpenFoodFactsProduct?> getProductByBarcode(String barcode) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_baseUrl/product/$barcode?fields=product_name,brands,image_url,nutriments,serving_size,categories,nutriscore_grade,nova_group',
        ),
        headers: {
          'User-Agent': 'NutriVision/1.0 (Flutter App)',
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to fetch product (HTTP ${response.statusCode})');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as int?;

      if (status != 1) {
        // Product not found
        return null;
      }

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      return OpenFoodFactsProduct.fromJson(product);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch product: $e');
    }
  }
}

/// Parsed product from Open Food Facts
class OpenFoodFactsProduct {
  final String? name;
  final String? brand;
  final String? imageUrl;
  final String? servingSize;
  final String? categories;
  final String? nutriscoreGrade;
  final int? novaGroup;

  // Nutriments per 100g
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugar;
  final double? saturatedFat;
  final double? sodium;
  final double? salt;

  const OpenFoodFactsProduct({
    this.name,
    this.brand,
    this.imageUrl,
    this.servingSize,
    this.categories,
    this.nutriscoreGrade,
    this.novaGroup,
    this.calories = 0,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.saturatedFat,
    this.sodium,
    this.salt,
  });

  String get displayName {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) parts.add(name!);
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    return parts.isNotEmpty ? parts.join(' – ') : 'Unknown Product';
  }

  /// Extract a list of health notes based on nutritional data
  List<String> get healthNotes {
    final notes = <String>[];

    if (nutriscoreGrade != null) {
      notes.add('Nutri-Score: ${nutriscoreGrade!.toUpperCase()}');
    }
    if (novaGroup != null) {
      final descriptions = {
        1: 'Unprocessed or minimally processed foods',
        2: 'Processed culinary ingredients',
        3: 'Processed foods',
        4: 'Ultra-processed food and drink products',
      };
      notes.add('NOVA Group $novaGroup: ${descriptions[novaGroup] ?? 'Unknown'}');
    }
    if (protein >= 20) {
      notes.add('High in protein (${protein.toStringAsFixed(1)}g per 100g)');
    }
    if (fiber >= 6) {
      notes.add('High in fiber (${fiber.toStringAsFixed(1)}g per 100g)');
    }
    if (sugar >= 22.5) {
      notes.add('⚠️ High in sugar (${sugar.toStringAsFixed(1)}g per 100g)');
    }
    if (saturatedFat != null && saturatedFat! >= 5) {
      notes.add('⚠️ High in saturated fat (${saturatedFat!.toStringAsFixed(1)}g per 100g)');
    }
    if (salt != null && salt! >= 1.5) {
      notes.add('⚠️ High in salt (${salt!.toStringAsFixed(1)}g per 100g)');
    }

    return notes;
  }

  factory OpenFoodFactsProduct.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    return OpenFoodFactsProduct(
      name: json['product_name'] as String?,
      brand: json['brands'] as String?,
      imageUrl: json['image_url'] as String?,
      servingSize: json['serving_size'] as String?,
      categories: json['categories'] as String?,
      nutriscoreGrade: json['nutriscore_grade'] as String?,
      novaGroup: json['nova_group'] as int?,
      calories: _parseNutrient(nutriments, 'energy-kcal_100g'),
      protein: _parseNutrient(nutriments, 'proteins_100g'),
      carbohydrates: _parseNutrient(nutriments, 'carbohydrates_100g'),
      fat: _parseNutrient(nutriments, 'fat_100g'),
      fiber: _parseNutrient(nutriments, 'fiber_100g'),
      sugar: _parseNutrient(nutriments, 'sugars_100g'),
      saturatedFat: _parseNutrientNullable(nutriments, 'saturated-fat_100g'),
      sodium: _parseNutrientNullable(nutriments, 'sodium_100g'),
      salt: _parseNutrientNullable(nutriments, 'salt_100g'),
    );
  }

  static double _parseNutrient(Map<String, dynamic> n, String key) {
    final value = n[key];
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _parseNutrientNullable(Map<String, dynamic> n, String key) {
    final value = n[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
