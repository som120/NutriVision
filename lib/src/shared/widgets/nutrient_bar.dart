import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Reusable nutrient progress bar with label and value
class NutrientBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;

  const NutrientBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              '${current.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}$unit',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 8,
              width: MediaQuery.sizeOf(context).width * 0.6 * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
