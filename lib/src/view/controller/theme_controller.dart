import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/src/core/theme/theme_services.dart';

class ThemeController extends GetxController {
  final ThemeService _themeService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeController(this._themeService);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    _themeMode = await _themeService.themeMode();
    update();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    Get.changeThemeMode(newThemeMode);
    update();
    await _themeService.updateThemeMode(newThemeMode);
  }

  Future<void> toggleTheme() async {
    final newThemeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await updateThemeMode(newThemeMode);
  }
}
