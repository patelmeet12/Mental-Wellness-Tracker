import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.overwhelmed,
    ),
    cardColor: AppColors.darkSurface,
    dividerColor: AppColors.darkBorder,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMD,
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      elevation: AppElevations.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface.withOpacity(0.5),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.overwhelmed),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.overwhelmed,
    ),
    cardColor: AppColors.lightSurface,
    dividerColor: AppColors.lightBorder,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.lightTextPrimary,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.lightTextSecondary,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMD,
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      elevation: AppElevations.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderMD,
        borderSide: const BorderSide(color: AppColors.overwhelmed),
      ),
    ),
  );
}
