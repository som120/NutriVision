import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// User profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    final goals = ref.watch(userGoalsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                'Profile',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // Avatar
              currentUser.when(
                data: (user) {
                  return Column(
                    spacing: 12,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName ?? 'U')
                                .split('')
                                .first
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        user?.displayName ?? 'User',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              // Nutrition Goals
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Goals',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showEditGoalsSheet(context, ref, goals);
                          },
                          icon: const Icon(Icons.edit_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _GoalRow(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Calories',
                      value:
                          '${_formatNumber(goals.calories)} kcal',
                      color: AppColors.calories,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.fitness_center_rounded,
                      label: 'Protein',
                      value: '${goals.protein.toStringAsFixed(0)}g',
                      color: AppColors.protein,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.grain_rounded,
                      label: 'Carbs',
                      value: '${goals.carbs.toStringAsFixed(0)}g',
                      color: AppColors.carbs,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.water_drop_rounded,
                      label: 'Fat',
                      value: '${goals.fat.toStringAsFixed(0)}g',
                      color: AppColors.fat,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Settings
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark Mode',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) {
                          // TODO: Toggle theme
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About',
                      onTap: () {},
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

              const SizedBox(height: 16),

              // Sign Out
              GlassCard(
                margin: EdgeInsets.zero,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(authNotifierProvider.notifier).signOut();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                    Text(
                      'Sign Out',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    final intValue = value.toInt();
    if (intValue >= 1000) {
      return '${(intValue / 1000).toStringAsFixed(intValue % 1000 == 0 ? 0 : 1)},${(intValue % 1000).toString().padLeft(3, '0')}';
    }
    return intValue.toString();
  }

  void _showEditGoalsSheet(
    BuildContext context,
    WidgetRef ref,
    UserGoals currentGoals,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditGoalsSheet(
        currentGoals: currentGoals,
        onSave: (calories, protein, carbs, fat) async {
          Navigator.pop(ctx);
          final success =
              await ref.read(authNotifierProvider.notifier).updateUserGoals(
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                  );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Goals updated! 🎯'
                      : 'Failed to update goals. Please try again.',
                ),
                backgroundColor: success ? AppColors.primary : AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Bottom sheet for editing daily goals
class _EditGoalsSheet extends StatefulWidget {
  final UserGoals currentGoals;
  final void Function(double calories, double protein, double carbs, double fat)
      onSave;

  const _EditGoalsSheet({
    required this.currentGoals,
    required this.onSave,
  });

  @override
  State<_EditGoalsSheet> createState() => _EditGoalsSheetState();
}

class _EditGoalsSheetState extends State<_EditGoalsSheet> {
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _caloriesController = TextEditingController(
      text: widget.currentGoals.calories.toStringAsFixed(0),
    );
    _proteinController = TextEditingController(
      text: widget.currentGoals.protein.toStringAsFixed(0),
    );
    _carbsController = TextEditingController(
      text: widget.currentGoals.carbs.toStringAsFixed(0),
    );
    _fatController = TextEditingController(
      text: widget.currentGoals.fat.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Daily Goals',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Set your daily nutrition targets. These will be saved to your account.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 24),

              _GoalInputField(
                controller: _caloriesController,
                label: 'Calories',
                unit: 'kcal',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.calories,
              ),
              const SizedBox(height: 16),
              _GoalInputField(
                controller: _proteinController,
                label: 'Protein',
                unit: 'g',
                icon: Icons.fitness_center_rounded,
                color: AppColors.protein,
              ),
              const SizedBox(height: 16),
              _GoalInputField(
                controller: _carbsController,
                label: 'Carbs',
                unit: 'g',
                icon: Icons.grain_rounded,
                color: AppColors.carbs,
              ),
              const SizedBox(height: 16),
              _GoalInputField(
                controller: _fatController,
                label: 'Fat',
                unit: 'g',
                icon: Icons.water_drop_rounded,
                color: AppColors.fat,
              ),

              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final calories = double.tryParse(_caloriesController.text) ?? 2000;
    final protein = double.tryParse(_proteinController.text) ?? 50;
    final carbs = double.tryParse(_carbsController.text) ?? 300;
    final fat = double.tryParse(_fatController.text) ?? 65;

    widget.onSave(calories, protein, carbs, fat);
  }
}

/// Styled input field for goal editing
class _GoalInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;

  const _GoalInputField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final num = double.tryParse(value);
        if (num == null || num <= 0) return 'Enter a valid number';
        return null;
      },
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Goal row item
class _GoalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _GoalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Settings tile item
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 22),
      onTap: onTap,
    );
  }
}
