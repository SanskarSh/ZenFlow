import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  final SharedPreferences _prefs;
  static const _themeKey = 'theme_mode';

  ThemeService(this._prefs);

  Future<ThemeMode> themeMode() async {
    final value = _prefs.getString(_themeKey);
    return _parseThemeMode(value);
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    await _prefs.setString(_themeKey, theme.toString());
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
