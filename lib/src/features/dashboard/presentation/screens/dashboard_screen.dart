import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/nutrient_bar.dart';
import '../../../../shared/widgets/nutri_progress_ring.dart';
import '../../../scanner/domain/entities/meal_entity.dart';
import '../providers/dashboard_provider.dart';

/// Main dashboard screen showing today's nutrition summary
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayLog = ref.watch(todayLogProvider);
    final todayMeals = ref.watch(todayMealsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _DashboardHeader()),

            // Calorie Ring Card
            SliverToBoxAdapter(
              child: todayLog.when(
                data: (log) => _CalorieRingCard(
                  calories: log?.totalCalories ?? 0,
                  goal: 2000,
                  protein: log?.totalProtein ?? 0,
                  carbs: log?.totalCarbs ?? 0,
                  fat: log?.totalFat ?? 0,
                ),
                loading: () => const _CalorieRingCard(
                  calories: 0,
                  goal: 2000,
                  protein: 0,
                  carbs: 0,
                  fat: 0,
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Macros Breakdown
            SliverToBoxAdapter(
              child: todayLog.when(
                data: (log) => _MacrosCard(
                  protein: log?.totalProtein ?? 0,
                  carbs: log?.totalCarbs ?? 0,
                  fat: log?.totalFat ?? 0,
                  fiber: log?.totalFiber ?? 0,
                ),
                loading: () =>
                    const _MacrosCard(protein: 0, carbs: 0, fat: 0, fiber: 0),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Weekly Chart
            SliverToBoxAdapter(child: _WeeklyChartCard()),

            // Today's Meals
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  "Today's Meals",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Meal List
            todayMeals.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyMealsPlaceholder());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        RepaintBoundary(child: _MealCard(meal: meals[index])),
                    childCount: meals.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

/// Dashboard header with greeting and date
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMM d').format(now),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}

/// Large calorie ring card
class _CalorieRingCard extends StatelessWidget {
  final double calories;
  final double goal;
  final double protein;
  final double carbs;
  final double fat;

  const _CalorieRingCard({
    required this.calories,
    required this.goal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (goal - calories).clamp(0, goal);
    final progress = goal > 0 ? calories / goal : 0.0;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NutriProgressRing(
            progress: progress,
            size: 180,
            strokeWidth: 14,
            gradient: AppColors.calorieGradient,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calories.toStringAsFixed(0),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.calories,
                  ),
                ),
                Text(
                  'kcal eaten',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${remaining.toStringAsFixed(0)} remaining',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick macro summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickMacro(
                label: 'Protein',
                value: protein,
                color: AppColors.protein,
                icon: Icons.fitness_center_rounded,
              ),
              _QuickMacro(
                label: 'Carbs',
                value: carbs,
                color: AppColors.carbs,
                icon: Icons.grain_rounded,
              ),
              _QuickMacro(
                label: 'Fat',
                value: fat,
                color: AppColors.fat,
                icon: Icons.water_drop_rounded,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1);
  }
}

/// Quick macro stat chip
class _QuickMacro extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _QuickMacro({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      spacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// Macronutrient breakdown card with progress bars
class _MacrosCard extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const _MacrosCard({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            'Macronutrients',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          NutrientBar(
            label: 'Protein',
            current: protein,
            goal: 50,
            color: AppColors.protein,
          ),
          NutrientBar(
            label: 'Carbohydrates',
            current: carbs,
            goal: 300,
            color: AppColors.carbs,
          ),
          NutrientBar(
            label: 'Fat',
            current: fat,
            goal: 65,
            color: AppColors.fat,
          ),
          NutrientBar(
            label: 'Fiber',
            current: fiber,
            goal: 25,
            color: AppColors.fiber,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1);
  }
}

/// Weekly calorie chart card
class _WeeklyChartCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weeklyLogs = ref.watch(weeklyLogsProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: weeklyLogs.when(
              data: (logs) {
                final barGroups = <BarChartGroupData>[];
                final now = DateTime.now();

                for (int i = 6; i >= 0; i--) {
                  final date = now.subtract(Duration(days: i));
                  final log = logs.where((l) {
                    return l.date.year == date.year &&
                        l.date.month == date.month &&
                        l.date.day == date.day;
                  });

                  final calories = log.isNotEmpty
                      ? log.first.totalCalories
                      : 0.0;

                  barGroups.add(
                    BarChartGroupData(
                      x: 6 - i,
                      barRods: [
                        BarChartRodData(
                          toY: calories,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          gradient: calories > 0
                              ? AppColors.primaryGradient
                              : null,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ],
                    ),
                  );
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2500,
                    barGroups: barGroups,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final now = DateTime.now();
                            final dayIndex =
                                (now.weekday - 1 + value.toInt() - 6) % 7;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[dayIndex < 0 ? dayIndex + 7 : dayIndex],
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('Error')),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1);
  }
}

/// Empty meals placeholder
class _EmptyMealsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        spacing: 12,
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          Text(
            'No meals logged today',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Tap the camera button to scan your food',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Individual meal card
class _MealCard extends StatelessWidget {
  final MealEntity meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm a').format(meal.loggedAt);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Meal type icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                meal.mealType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Meal info
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
                Row(
                  children: [
                    Text(
                      meal.mealType.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(' · $timeStr', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                meal.calories.toStringAsFixed(0),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.calories,
                ),
              ),
              Text(
                'kcal',
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
