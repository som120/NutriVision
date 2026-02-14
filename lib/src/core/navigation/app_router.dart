import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/dashboard/presentation/screens/app_shell.dart';

/// App navigation configuration
class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';

  /// Generate routes based on auth state
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}

/// Auth wrapper that redirects based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const AppShell();
        }
        return const LoginScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginScreen(),
    );
  }
}
