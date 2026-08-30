import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final savedTheme = StorageService.getThemeMode();

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      case 'system':
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    String value;

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.dark:
        value = 'dark';
        break;

      case ThemeMode.system:
        value = 'system';
        break;
    }

    await StorageService.saveThemeMode(value);

    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    await setThemeMode(
      enabled ? ThemeMode.dark : ThemeMode.light,
    );
  }

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }
}
