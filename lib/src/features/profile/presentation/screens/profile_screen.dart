import 'package:flutter/material.dart';
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
                            // TODO: Edit goals
                          },
                          icon: const Icon(Icons.edit_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _GoalRow(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Calories',
                      value: '2,000 kcal',
                      color: AppColors.calories,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.fitness_center_rounded,
                      label: 'Protein',
                      value: '50g',
                      color: AppColors.protein,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.grain_rounded,
                      label: 'Carbs',
                      value: '300g',
                      color: AppColors.carbs,
                    ),
                    const Divider(height: 24),
                    _GoalRow(
                      icon: Icons.water_drop_rounded,
                      label: 'Fat',
                      value: '65g',
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
