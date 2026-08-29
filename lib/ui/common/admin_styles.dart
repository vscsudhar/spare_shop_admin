import 'package:flutter/material.dart';

class AdminColors {
  static bool isDarkTheme = false;

  static Color get sidebarBackground => const Color(0xFF0D1321);
  static Color get sidebarActiveText => const Color(0xFF10B981);
  static Color get accentLime => const Color(0xFFB4F232);
  static Color get primaryGreen => const Color(0xFF0F9F59);

  static Color get background =>
      isDarkTheme ? const Color(0xFF0B0F19) : const Color(0xFFF9FAFB);
  static Color get panelBackground =>
      isDarkTheme ? const Color(0xFF151D30) : Colors.white;
  static Color get border =>
      isDarkTheme ? const Color(0xFF24304F) : const Color(0xFFE5E7EB);

  // Statuses
  static Color get success => const Color(0xFF10B981);
  static Color get pending => const Color(0xFFF59E0B);
  static Color get inProgress => const Color(0xFF3B82F6);
  static Color get cancelled => const Color(0xFFEF4444);

  // Texts
  static Color get textPrimary =>
      isDarkTheme ? Colors.white : const Color(0xFF111827);
  static Color get textSecondary =>
      isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
  static Color get textLight =>
      isDarkTheme ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
}

class AdminTextStyles {
  static TextStyle get header => TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AdminColors.textPrimary,
      );

  static TextStyle get sectionHeader => TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AdminColors.textPrimary,
      );

  static TextStyle get cardTitle => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AdminColors.textSecondary,
      );

  static TextStyle get cardValue => TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AdminColors.textPrimary,
      );

  static TextStyle get body => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: AdminColors.textPrimary,
      );

  static TextStyle get bodySecondary => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: AdminColors.textSecondary,
      );

  static TextStyle get tableHeader => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AdminColors.textSecondary,
      );
}

class AdminSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class AdminRadius {
  static const double card = 16.0;
  static const double input = 12.0;
  static const double chip = 8.0;
}

class AdminShadows {
  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: AdminColors.isDarkTheme ? 0.2 : 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      );
}

class AdminBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;
}
