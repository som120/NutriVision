import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/nutrient_bar.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/meal_entity.dart';
import '../providers/scanner_provider.dart';

/// Barcode scanner screen that opens camera, scans barcode,
/// fetches nutrition from Open Food Facts, and lets user save the meal.
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late MobileScannerController _cameraController;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodes) {
    if (_hasScanned) return;
    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasScanned = true;
    _cameraController.stop();

    ref.read(barcodeNotifierProvider.notifier).lookupBarcode(
          barcode.rawValue!,
        );
  }

  void _resetScanner() {
    _hasScanned = false;
    ref.read(barcodeNotifierProvider.notifier).reset();
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    final barcodeState = ref.watch(barcodeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            ref.read(barcodeNotifierProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: barcodeState.isLoading
          ? _LoadingView()
          : barcodeState.scannedProduct != null
              ? _BarcodeResultView(
                  meal: barcodeState.scannedProduct!,
                  onReset: _resetScanner,
                )
              : barcodeState.saved
                  ? _BarcodeSavedView(
                      onScanAnother: _resetScanner,
                      onDone: () {
                        ref.read(barcodeNotifierProvider.notifier).reset();
                        Navigator.pop(context);
                      },
                    )
                  : _ScannerCameraView(
                      controller: _cameraController,
                      onDetect: _onDetect,
                      errorMessage: barcodeState.errorMessage,
                      onRetry: _resetScanner,
                    ),
    );
  }
}

/// Live camera view with barcode scanning overlay
class _ScannerCameraView extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ScannerCameraView({
    required this.controller,
    required this.onDetect,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan Again'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
        ),

        // Scanning overlay
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.8),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.97, end: 1.03, duration: 1500.ms),
        ),

        // Bottom instruction
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  Text(
                    'Point at a barcode',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
        ),

        // Top left: flashlight toggle
        Positioned(
          top: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.8),
            child: IconButton(
              icon: const Icon(Icons.flash_on_rounded, size: 20),
              onPressed: () => controller.toggleTorch(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading view while fetching product details
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppColors.primary,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(duration: 2.seconds),
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 36,
                  color: AppColors.primary,
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1500.ms),
              ],
            ),
          ),
          Text(
            'Looking up product...',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Fetching nutritional information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Result view showing scanned product nutrition
class _BarcodeResultView extends ConsumerWidget {
  final MealEntity meal;
  final VoidCallback onReset;

  const _BarcodeResultView({required this.meal, required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barcodeState = ref.watch(barcodeNotifierProvider);
    final goals = ref.watch(userGoalsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Product Image
          if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: meal.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.contain,
                placeholder: (_, _) => Container(
                  height: 220,
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.lightElevated,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),

          // Product name & category
          GlassCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Barcode badge
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meal.foodName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.foodCategory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.straighten_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(meal.servingSize,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

          // Calories
          GlassCard(
                margin: EdgeInsets.zero,
                gradient: AppColors.calorieGradient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      meal.calories.toStringAsFixed(0),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'kcal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          // Macronutrients
          GlassCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 14,
              children: [
                Row(
                  children: [
                    Text(
                      'Macronutrients',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'per 100g',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                NutrientBar(
                  label: 'Protein',
                  current: meal.macronutrients.protein,
                  goal: goals.protein,
                  color: AppColors.protein,
                ),
                NutrientBar(
                  label: 'Carbohydrates',
                  current: meal.macronutrients.carbohydrates,
                  goal: goals.carbs,
                  color: AppColors.carbs,
                ),
                NutrientBar(
                  label: 'Fat',
                  current: meal.macronutrients.fat,
                  goal: goals.fat,
                  color: AppColors.fat,
                ),
                NutrientBar(
                  label: 'Fiber',
                  current: meal.macronutrients.fiber,
                  goal: 25,
                  color: AppColors.fiber,
                ),
                NutrientBar(
                  label: 'Sugar',
                  current: meal.macronutrients.sugar,
                  goal: 50,
                  color: AppColors.sugar,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          // Health Notes
          if (meal.healthNotes.isNotEmpty)
            GlassCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...meal.healthNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            note.startsWith('⚠')
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                            color: note.startsWith('⚠')
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

          // Meal Type Selector
          GlassCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealType.values.map((type) {
                    final isSelected = meal.mealType == type;
                    return ChoiceChip(
                      label: Text('${type.emoji} ${type.label}'),
                      selected: isSelected,
                      onSelected: (_) {
                        ref
                            .read(barcodeNotifierProvider.notifier)
                            .updateMealType(type);
                      },
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

          const SizedBox(height: 8),

          // Error
          if (barcodeState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                barcodeState.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),

          // Action buttons
          Row(
            spacing: 12,
            children: [
              // Scan another
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan Again'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              // Save
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: barcodeState.isLoading
                        ? null
                        : () async {
                            final success = await ref
                                .read(barcodeNotifierProvider.notifier)
                                .saveMeal();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Product saved! 📦'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                    icon: barcodeState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                        barcodeState.isLoading ? 'Saving...' : 'Save'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Success view after saving barcode product
class _BarcodeSavedView extends StatelessWidget {
  final VoidCallback onScanAnother;
  final VoidCallback onDone;

  const _BarcodeSavedView({
    required this.onScanAnother,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut,
                  duration: 800.ms,
                ),
            Text(
              'Product Saved!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 300.ms),
            Text(
              'Nutritional data has been logged',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                OutlinedButton.icon(
                  onPressed: onScanAnother,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan Another'),
                ),
                ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
