import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:stacked/stacked.dart';

enum AppThemePreference {
  light,
  dark,
  system,
}

class ThemeService with ListenableServiceMixin {
  static const String _themeKey = 'theme_preference';

  final ReactiveValue<AppThemePreference> _themePreference =
      ReactiveValue<AppThemePreference>(AppThemePreference.system);

  AppThemePreference get themePreference => _themePreference.value;

  ThemeService() {
    listenToReactiveValues([_themePreference]);
    _loadTheme();
  }

  ThemeMode get themeMode {
    switch (_themePreference.value) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefStr = prefs.getString(_themeKey);
      if (prefStr != null) {
        if (prefStr == 'light') {
          _themePreference.value = AppThemePreference.light;
        } else if (prefStr == 'dark') {
          _themePreference.value = AppThemePreference.dark;
        } else {
          _themePreference.value = AppThemePreference.system;
        }
      }
    } catch (_) {}
    _syncAdminTheme();
  }

  void _syncAdminTheme() {
    if (_themePreference.value == AppThemePreference.light) {
      AdminColors.isDarkTheme = false;
    } else if (_themePreference.value == AppThemePreference.dark) {
      AdminColors.isDarkTheme = true;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      AdminColors.isDarkTheme = brightness == Brightness.dark;
    }
  }

  Future<void> setLightTheme() async {
    _themePreference.value = AppThemePreference.light;
    _syncAdminTheme();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, 'light');
    } catch (_) {}
  }

  Future<void> setDarkTheme() async {
    _themePreference.value = AppThemePreference.dark;
    _syncAdminTheme();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, 'dark');
    } catch (_) {}
  }

  Future<void> setSystemTheme() async {
    _themePreference.value = AppThemePreference.system;
    _syncAdminTheme();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, 'system');
    } catch (_) {}
  }
}
