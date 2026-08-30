import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================================
  // LOAD SAVED THEME
  // ============================================================

  Future<void> loadTheme() async {
    final String value = StorageService.getThemeMode();

    _themeMode = _themeModeFromString(value);

    notifyListeners();
  }

  // ============================================================
  // SET THEME MODE
  // ============================================================

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    _themeMode = mode;

    await StorageService.saveThemeMode(
      _themeModeToString(mode),
    );

    notifyListeners();
  }

  // ============================================================
  // DARK MODE HELPER
  // ============================================================

  Future<void> setDarkMode(
    bool enabled,
  ) async {
    await setThemeMode(
      enabled ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // ============================================================
  // STRING → THEME MODE
  // ============================================================

  ThemeMode _themeModeFromString(
    String value,
  ) {
    switch (value) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  // ============================================================
  // THEME MODE → STRING
  // ============================================================

  String _themeModeToString(
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';

      case ThemeMode.dark:
        return 'dark';

      case ThemeMode.system:
        return 'system';
    }
  }
}
