import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/meal_remote_data_source.dart';
import '../../data/datasources/open_food_facts_data_source.dart';
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

// ─── Barcode Scanner ─────────────────────────────────────────
final openFoodFactsDataSourceProvider =
    Provider<OpenFoodFactsDataSource>((ref) {
  return OpenFoodFactsDataSource();
});

final barcodeNotifierProvider =
    NotifierProvider<BarcodeNotifier, BarcodeState>(BarcodeNotifier.new);

/// Barcode scan state
class BarcodeState {
  final bool isLoading;
  final String? errorMessage;
  final MealEntity? scannedProduct;
  final bool saved;

  const BarcodeState({
    this.isLoading = false,
    this.errorMessage,
    this.scannedProduct,
    this.saved = false,
  });

  BarcodeState copyWith({
    bool? isLoading,
    String? errorMessage,
    MealEntity? scannedProduct,
    bool? saved,
  }) {
    return BarcodeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      scannedProduct: scannedProduct ?? this.scannedProduct,
      saved: saved ?? this.saved,
    );
  }
}

/// Notifier that handles barcode lookup via Open Food Facts
class BarcodeNotifier extends Notifier<BarcodeState> {
  @override
  BarcodeState build() => const BarcodeState();

  MealRepository get _repository => ref.read(scannerMealRepositoryProvider);

  /// Look up a barcode and convert to MealEntity
  Future<void> lookupBarcode(String barcode) async {
    state = const BarcodeState(isLoading: true);

    try {
      final dataSource = ref.read(openFoodFactsDataSourceProvider);
      final product = await dataSource.getProductByBarcode(barcode);

      if (product == null) {
        state = const BarcodeState(
          errorMessage: 'Product not found in database. Try another barcode.',
        );
        return;
      }

      final meal = MealEntity(
        id: '',
        userId: '',
        foodName: product.displayName,
        imageUrl: product.imageUrl,
        servingSize: product.servingSize ?? 'per 100g',
        calories: product.calories,
        macronutrients: Macronutrients(
          protein: product.protein,
          carbohydrates: product.carbohydrates,
          fat: product.fat,
          fiber: product.fiber,
          sugar: product.sugar,
        ),
        micronutrients: product.sodium != null
            ? Micronutrients(
                sodium: MicronutrientValue(
                  value: product.sodium! * 1000, // convert g to mg
                  unit: 'mg',
                ),
              )
            : null,
        confidenceScore: 1.0,
        foodCategory: _extractCategory(product.categories),
        healthNotes: product.healthNotes,
        mealType: MealType.snack,
        loggedAt: DateTime.now(),
      );

      state = BarcodeState(scannedProduct: meal);
    } catch (e) {
      state = BarcodeState(
        errorMessage: 'Failed to look up barcode: $e',
      );
    }
  }

  /// Save the barcode-scanned product
  Future<bool> saveMeal() async {
    if (state.scannedProduct == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.saveMeal(state.scannedProduct!);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (id) {
        state = state.copyWith(isLoading: false, saved: true);
        return true;
      },
    );
  }

  /// Update meal type before saving
  void updateMealType(MealType type) {
    if (state.scannedProduct == null) return;
    state = state.copyWith(
      scannedProduct: state.scannedProduct!.copyWith(mealType: type),
    );
  }

  void reset() {
    state = const BarcodeState();
  }

  String _extractCategory(String? categories) {
    if (categories == null || categories.isEmpty) return 'Packaged Food';
    // Take the first category from the comma-separated list
    final first = categories.split(',').first.trim();
    // Remove language prefix if present (e.g., "en:snacks" → "Snacks")
    final cleaned = first.contains(':') ? first.split(':').last : first;
    // Capitalize first letter
    if (cleaned.isEmpty) return 'Packaged Food';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
