import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Branding
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF8B5CF6); // Violet
  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Dark Theme Colors (Default Premium Look)
  static const Color darkBg = Color(0xFF0B0F19); // Deep Slate Navy
  static const Color darkSurface = Color(0xFF161E31); // Translucent Dark Blue-Grey
  static const Color darkBorder = Color(0xFF2E3B52); // Glass border for dark mode
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC); // Cool Slate Grey
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0); // Glass border for light mode
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Mood/Status Colors
  static const Color excellent = Color(0xFF10B981); // Emerald Green
  static const Color good = Color(0xFF3B82F6); // Bright Blue
  static const Color neutral = Color(0xFF6B7280); // Neutral Grey
  static const Color stressed = Color(0xFFF59E0B); // Amber Warning
  static const Color overwhelmed = Color(0xFFEF4444); // Red Alarm

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wellnessGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stressGradient = LinearGradient(
    colors: [stressed, overwhelmed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphic Shadows
  static List<BoxShadow> getGlassShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.08),
        blurRadius: 16,
        spreadRadius: -4,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
