import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        surface: AppColors.panelBackgroundLight,
        shadow: Colors.black12,
        outline: AppColors.borderLight,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.panelBackgroundLight,
        elevation: 0,
      ),
      dividerColor: AppColors.borderLight,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelBackgroundLight,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        surface: AppColors.panelBackgroundDark,
        shadow: Colors.black38,
        outline: AppColors.borderDark,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.panelBackgroundDark,
        elevation: 0,
      ),
      dividerColor: AppColors.borderDark,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelBackgroundDark,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
      ),
      useMaterial3: true,
    );
  }
}
