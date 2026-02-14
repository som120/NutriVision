import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/meal_remote_data_source.dart';
import '../../data/repositories/meal_repository_impl.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/meal_repository.dart';

// ─── Repository Provider ─────────────────────────────────────
final scannerMealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(remoteDataSource: MealRemoteDataSource());
});

// ─── Scanner Notifier ────────────────────────────────────────
final scannerNotifierProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);

/// Scanner state
class ScannerState {
  final bool isAnalyzing;
  final bool isSaving;
  final String? errorMessage;
  final MealEntity? analyzedMeal;
  final bool saved;

  const ScannerState({
    this.isAnalyzing = false,
    this.isSaving = false,
    this.errorMessage,
    this.analyzedMeal,
    this.saved = false,
  });

  ScannerState copyWith({
    bool? isAnalyzing,
    bool? isSaving,
    String? errorMessage,
    MealEntity? analyzedMeal,
    bool? saved,
  }) {
    return ScannerState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      analyzedMeal: analyzedMeal ?? this.analyzedMeal,
      saved: saved ?? this.saved,
    );
  }
}

/// Scanner state notifier
class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => const ScannerState();

  MealRepository get _repository => ref.read(scannerMealRepositoryProvider);

  /// Analyze a food image
  Future<void> analyzeFood({
    required String imagePath,
    MealType mealType = MealType.snack,
  }) async {
    state = const ScannerState(isAnalyzing: true);

    final result = await _repository.analyzeFood(
      imagePath: imagePath,
      mealType: mealType,
    );

    result.fold(
      (failure) {
        state = ScannerState(errorMessage: failure.message);
      },
      (meal) {
        state = ScannerState(analyzedMeal: meal);
      },
    );
  }

  /// Save the analyzed meal
  Future<bool> saveMeal() async {
    if (state.analyzedMeal == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final result = await _repository.saveMeal(state.analyzedMeal!);

    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (id) {
        state = state.copyWith(isSaving: false, saved: true);
        return true;
      },
    );
  }

  /// Update meal type before saving
  void updateMealType(MealType type) {
    if (state.analyzedMeal == null) return;
    state = state.copyWith(
      analyzedMeal: state.analyzedMeal!.copyWith(mealType: type),
    );
  }

  /// Reset scanner state
  void reset() {
    state = const ScannerState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
