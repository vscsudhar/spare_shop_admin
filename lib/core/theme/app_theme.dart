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
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 11,
          fontFamily: 'Inter',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelBackgroundLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          color: AppColors.textLightLight,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.textSecondaryLight,
        suffixIconColor: AppColors.textSecondaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.borderLight.withValues(alpha: 0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cancelled, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cancelled, width: 2.0),
        ),
        errorStyle: const TextStyle(color: AppColors.cancelled, fontSize: 12),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle:
            TextStyle(color: AppColors.textPrimaryLight, fontSize: 13),
        menuStyle: MenuStyle(
          backgroundColor:
              WidgetStatePropertyAll(AppColors.panelBackgroundLight),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.panelBackgroundLight,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: AppColors.textPrimaryLight, fontSize: 13),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.panelBackgroundLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.panelBackgroundLight,
        modalBackgroundColor: AppColors.panelBackgroundLight,
        surfaceTintColor: Colors.transparent,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryGreen,
        selectionColor: AppColors.primaryGreen.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primaryGreen,
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
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 11,
          fontFamily: 'Inter',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelBackgroundDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          color: AppColors.textLightDark,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.accentLime,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.borderDark.withValues(alpha: 0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cancelled, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cancelled, width: 2.0),
        ),
        errorStyle: const TextStyle(color: AppColors.cancelled, fontSize: 12),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle:
            TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
        menuStyle: MenuStyle(
          backgroundColor:
              WidgetStatePropertyAll(AppColors.panelBackgroundDark),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.panelBackgroundDark,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.panelBackgroundDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.panelBackgroundDark,
        modalBackgroundColor: AppColors.panelBackgroundDark,
        surfaceTintColor: Colors.transparent,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryGreen,
        selectionColor: AppColors.primaryGreen.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.primaryGreen,
      ),
      useMaterial3: true,
    );
  }
}
