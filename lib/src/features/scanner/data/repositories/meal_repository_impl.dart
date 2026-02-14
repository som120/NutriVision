import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_remote_data_source.dart';
import '../models/meal_model.dart';

/// Meal repository implementation
class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource _remoteDataSource;

  MealRepositoryImpl({required MealRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, MealEntity>> analyzeFood({
    required String imagePath,
    MealType mealType = MealType.snack,
  }) async {
    try {
      final meal = await _remoteDataSource.analyzeFood(
        imagePath: imagePath,
        mealType: mealType,
      );
      return Right(meal);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveMeal(MealEntity meal) async {
    try {
      final id = await _remoteDataSource.saveMeal(MealModel.fromEntity(meal));
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await _remoteDataSource.deleteMeal(mealId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByDate(
    DateTime date,
  ) async {
    try {
      final meals = await _remoteDataSource.getMealsByDate(date);
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final meals = await _remoteDataSource.getMealsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getRecentMeals({
    int limit = 10,
  }) async {
    try {
      final meals = await _remoteDataSource.getRecentMeals(limit: limit);
      return Right(meals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MealEntity>> watchTodayMeals() {
    return _remoteDataSource.watchTodayMeals();
  }
}
