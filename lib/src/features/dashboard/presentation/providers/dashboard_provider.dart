import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scanner/data/datasources/meal_remote_data_source.dart';
import '../../../scanner/data/repositories/meal_repository_impl.dart';
import '../../../scanner/domain/entities/meal_entity.dart';
import '../../../scanner/domain/repositories/meal_repository.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/datasources/weight_remote_data_source.dart';
import '../../data/models/weight_entry_model.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/entities/weight_entry.dart';
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

// ─── Weight Tracking ─────────────────────────────────────────
final weightRemoteDataSourceProvider = Provider<WeightRemoteDataSource>((ref) {
  return WeightRemoteDataSource();
});

/// Streams the last 90 days of weight entries in ascending date order.
final weightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) {
  final dataSource = ref.watch(weightRemoteDataSourceProvider);
  return dataSource.watchWeightEntries(days: 90);
});

/// Notifier for adding weight entries
final addWeightNotifierProvider =
    NotifierProvider<AddWeightNotifier, AddWeightState>(
  AddWeightNotifier.new,
);

class AddWeightState {
  final bool isLoading;
  final String? errorMessage;
  final bool saved;

  const AddWeightState({
    this.isLoading = false,
    this.errorMessage,
    this.saved = false,
  });

  AddWeightState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? saved,
  }) {
    return AddWeightState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      saved: saved ?? this.saved,
    );
  }
}

class AddWeightNotifier extends Notifier<AddWeightState> {
  @override
  AddWeightState build() => const AddWeightState();

  Future<bool> addWeight({
    required double weightKg,
    required DateTime date,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, saved: false);
    try {
      final dataSource = ref.read(weightRemoteDataSourceProvider);
      final entry = WeightEntryModel(
        id: '',
        userId: '',
        weightKg: weightKg,
        date: DateTime(date.year, date.month, date.day),
        createdAt: DateTime.now(),
      );
      await dataSource.addWeightEntry(entry);
      state = state.copyWith(isLoading: false, saved: true);
      // Refresh the weight entries stream
      ref.invalidate(weightEntriesProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const AddWeightState();
  }
}
