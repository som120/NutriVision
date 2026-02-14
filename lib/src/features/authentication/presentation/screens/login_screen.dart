import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Login screen with email/password and Google sign-in
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      // Navigation handled by auth state listener in router
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Background gradient
              Container(
                height: size.height * 0.45,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Logo & Title
                      Icon(
                        Icons.eco_rounded,
                        size: 64,
                        color: Colors.white,
                      ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                      const SizedBox(height: 16),
                      Text(
                            'NutriVision',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.3),
                      const SizedBox(height: 8),
                      Text(
                        'Your AI Nutrition Companion',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                      const SizedBox(height: 48),

                      // Login Form Card
                      Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 20,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),

                                  // Error message
                                  if (authState.errorMessage != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(
                                          alpha: 0.1,
                                        ),
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
                                              authState.errorMessage!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.error,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: 'Email address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Password field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          );
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        _showForgotPasswordDialog(context);
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : _handleLogin,
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Sign In'),
                                    ),
                                  ),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'or',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),

                                  // Google Sign In
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton.icon(
                                      onPressed: authState.isLoading
                                          ? null
                                          : _handleGoogleSignIn,
                                      icon: Image.network(
                                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                        height: 20,
                                        width: 20,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.g_mobiledata_rounded,
                                          size: 28,
                                        ),
                                      ),
                                      label: const Text('Continue with Google'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms)
                          .slideY(begin: 0.2),

                      const Spacer(),

                      // Sign Up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Password', style: theme.textTheme.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              style: theme.textTheme.bodyMedium,
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .sendPasswordResetEmail(emailController.text.trim());
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
