import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scanner/data/datasources/meal_remote_data_source.dart';
import '../../../scanner/data/repositories/meal_repository_impl.dart';
import '../../../scanner/domain/entities/meal_entity.dart';
import '../../../scanner/domain/repositories/meal_repository.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ─── Data Source Providers ────────────────────────────────────
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource();
});

final mealRemoteDataSourceProvider = Provider<MealRemoteDataSource>((ref) {
  return MealRemoteDataSource();
});

// ─── Repository Providers ────────────────────────────────────
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  );
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(
    remoteDataSource: ref.watch(mealRemoteDataSourceProvider),
  );
});

// ─── Dashboard State ─────────────────────────────────────────
final todayLogProvider = StreamProvider<DailyLog?>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchTodayLog();
});

final todayMealsProvider = StreamProvider<List<MealEntity>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.watchTodayMeals();
});

final weeklyLogsProvider = FutureProvider<List<DailyLog>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final result = await repo.getWeeklySummary();
  return result.fold((failure) => [], (logs) => logs);
});

final recentMealsProvider = FutureProvider<List<MealEntity>>((ref) async {
  final repo = ref.read(mealRepositoryProvider);
  final result = await repo.getRecentMeals(limit: 20);
  return result.fold((failure) => [], (meals) => meals);
});
