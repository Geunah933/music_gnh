import 'package:flutter/material.dart';
import '../core/database/hive_init.dart';
import '../core/database/hive_boxes.dart';

/// Manages the app-wide ThemeMode and persists it in Hive.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadFromHive();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadFromHive() {
    final box = HiveInit.settingsBox;
    final stored = box.get(HiveBoxes.themeMode, defaultValue: 'dark') as String;
    _themeMode = _parseThemeMode(stored);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    HiveInit.settingsBox.put(HiveBoxes.themeMode, _themeModeToString(mode));
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
