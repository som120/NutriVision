import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/meal_entity.dart';

/// Scanner/Meal repository interface
abstract class MealRepository {
  /// Analyze food image using AI and return nutritional data
  Future<Either<Failure, MealEntity>> analyzeFood({
    required String imagePath,
    MealType mealType = MealType.snack,
  });

  /// Save meal to Firestore
  Future<Either<Failure, String>> saveMeal(MealEntity meal);

  /// Delete meal from Firestore
  Future<Either<Failure, void>> deleteMeal(String mealId);

  /// Get meals for a specific date
  Future<Either<Failure, List<MealEntity>>> getMealsByDate(DateTime date);

  /// Get meals for a date range
  Future<Either<Failure, List<MealEntity>>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get recent meals (last N meals)
  Future<Either<Failure, List<MealEntity>>> getRecentMeals({int limit = 10});

  /// Stream of today's meals
  Stream<List<MealEntity>> watchTodayMeals();
}
