import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../scanner/domain/entities/meal_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

/// History screen showing past meals
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentMeals = ref.watch(recentMealsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Meal History',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Your recent food logs',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            // Meals list
            recentMeals.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          Text(
                            'No meals logged yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Start scanning food to build your history',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Group meals by date
                final grouped = <String, List<MealEntity>>{};
                for (final meal in meals) {
                  final key = DateFormat('yyyy-MM-dd').format(meal.loggedAt);
                  grouped.putIfAbsent(key, () => []).add(meal);
                }

                final entries = grouped.entries.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = entries[index];
                    final dateLabel = _formatDateLabel(entry.key);
                    final dayCalories = entry.value.fold<double>(
                      0,
                      (sum, m) => sum + m.calories,
                    );

                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateLabel,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.calories.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${dayCalories.toStringAsFixed(0)} kcal',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.calories,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Meals for this date
                            ...entry.value.map(
                              (meal) => RepaintBoundary(
                                child: _HistoryMealCard(meal: meal),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                        .slideY(begin: 0.05);
                  }, childCount: entries.length),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading history: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _formatDateLabel(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }
}

/// History meal card with details
class _HistoryMealCard extends StatelessWidget {
  final MealEntity meal;

  const _HistoryMealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm a').format(meal.loggedAt);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Meal type badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                meal.mealType.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.foodName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.mealType.label} · $timeStr · ${meal.servingSize}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Macros mini
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories.toStringAsFixed(0)} kcal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.calories,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P ${meal.macronutrients.protein.toStringAsFixed(0)}g · '
                'C ${meal.macronutrients.carbohydrates.toStringAsFixed(0)}g · '
                'F ${meal.macronutrients.fat.toStringAsFixed(0)}g',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
