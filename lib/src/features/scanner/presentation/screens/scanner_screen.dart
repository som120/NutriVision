import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/nutrient_bar.dart';
import '../../domain/entities/meal_entity.dart';
import '../providers/scanner_provider.dart';

/// Food scanner screen for capturing & analyzing food images
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      ref
          .read(scannerNotifierProvider.notifier)
          .analyzeFood(imagePath: image.path, mealType: MealType.snack);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      ref
          .read(scannerNotifierProvider.notifier)
          .analyzeFood(imagePath: image.path, mealType: MealType.snack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        leading: state.analyzedMeal != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  ref.read(scannerNotifierProvider.notifier).reset();
                },
              )
            : null,
      ),
      body: state.isAnalyzing
          ? _AnalyzingView()
          : state.analyzedMeal != null
          ? _ResultView(meal: state.analyzedMeal!)
          : state.saved
          ? _SuccessView(
              onDone: () {
                ref.read(scannerNotifierProvider.notifier).reset();
              },
            )
          : _CaptureView(
              onCamera: _captureImage,
              onGallery: _pickFromGallery,
              errorMessage: state.errorMessage,
            ),
    );
  }
}

/// Initial capture view with camera/gallery buttons
class _CaptureView extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final String? errorMessage;

  const _CaptureView({
    required this.onCamera,
    required this.onGallery,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

              Text(
                'Scan Your Food',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 300.ms),

              Text(
                'Take a photo of your meal and our AI will\nanalyze its nutritional content',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms),

              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Camera button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 24),
                  label: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

              // Gallery button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 24),
                  label: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 17),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Analyzing animation view
class _AnalyzingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppColors.primary,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(duration: 2.seconds),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: AppColors.primary,
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
              ],
            ),
          ),
          Text(
            'Analyzing your food...',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Our AI is identifying nutrients',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Analysis result view
class _ResultView extends ConsumerWidget {
  final MealEntity meal;

  const _ResultView({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(scannerNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Food Image
          if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(meal.imageUrl!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),

          // Food name & category
          GlassCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.foodName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Confidence badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(
                          meal.confidenceScore,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(meal.confidenceScore * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getConfidenceColor(meal.confidenceScore),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
                      color: AppColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(meal.servingSize, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

          // Calories highlight
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
                Text(
                  'Macronutrients',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                NutrientBar(
                  label: 'Protein',
                  current: meal.macronutrients.protein,
                  goal: 50,
                  color: AppColors.protein,
                ),
                NutrientBar(
                  label: 'Carbohydrates',
                  current: meal.macronutrients.carbohydrates,
                  goal: 300,
                  color: AppColors.carbs,
                ),
                NutrientBar(
                  label: 'Fat',
                  current: meal.macronutrients.fat,
                  goal: 65,
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
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.primary,
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
                            .read(scannerNotifierProvider.notifier)
                            .updateMealType(type);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
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

          // Save Button
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () async {
                      final success = await ref
                          .read(scannerNotifierProvider.notifier)
                          .saveMeal();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Meal saved! 🎉'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
              icon: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(state.isSaving ? 'Saving...' : 'Save Meal'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

/// Success view after saving
class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;

  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
            'Meal Saved!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 300.ms),
          Text(
            'Your nutrition data has been updated',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onDone,
            child: const Text('Scan Another'),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
