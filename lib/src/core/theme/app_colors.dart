import 'package:flutter/material.dart';

/// NutriVision Color Palette
class AppColors {
  AppColors._();

  // Primary palette - Vibrant green (health/nutrition)
  static const Color primary = Color(0xFF2DC653);
  static const Color primaryLight = Color(0xFF6EE89A);
  static const Color primaryDark = Color(0xFF0D9B3E);

  // Secondary palette - Deep teal
  static const Color secondary = Color(0xFF0A8F8F);
  static const Color secondaryLight = Color(0xFF4CC9C9);
  static const Color secondaryDark = Color(0xFF006666);

  // Accent - Warm orange for highlights/CTAs
  static const Color accent = Color(0xFFFF8C42);
  static const Color accentLight = Color(0xFFFFAE72);
  static const Color accentDark = Color(0xFFE06B1F);

  // Backgrounds - Dark theme
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2333);
  static const Color darkElevated = Color(0xFF242D3D);

  // Backgrounds - Light theme
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF0F2F5);

  // Text colors
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textPrimaryLight = Color(0xFF1B1F23);
  static const Color textSecondaryLight = Color(0xFF57606A);

  // Nutrient colors
  static const Color calories = Color(0xFFFF6B6B);
  static const Color protein = Color(0xFF4ECDC4);
  static const Color carbs = Color(0xFFFFD93D);
  static const Color fat = Color(0xFFFF8C42);
  static const Color fiber = Color(0xFF6BCB77);
  static const Color sugar = Color(0xFFE84393);

  // Status colors
  static const Color success = Color(0xFF2DC653);
  static const Color warning = Color(0xFFFFB323);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00C9A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1C2333), Color(0xFF242D3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calorieGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proteinGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient carbsGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFFA62E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fatGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFC5C65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
