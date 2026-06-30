import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryBlue,
      onSecondary: Colors.white,
      tertiary: AppColors.aqua,
      onTertiary: AppColors.primaryBlue,
      error: AppColors.red,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: AppColors.darkText),
        bodySmall: TextStyle(color: AppColors.darkText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.aqua,
        foregroundColor: AppColors.primaryBlue,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: AppColors.darkText.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.darkText.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.darkText.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondaryBlue,
      ),
    );
  }
}
