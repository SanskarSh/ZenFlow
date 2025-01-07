import 'package:flutter/material.dart';

class AppColors {
  final BuildContext context;

  // Light Theme Colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF6F8FF);
  static const Color lightPrimary = Color(0xFF6C63FF);
  static const Color lightSecondary = Color(0xFFFF6B95);
  static const Color lightTertiary = Color(0xFF63ECFF);
  static const Color lightAccent = Color(0xFFFFD93D);

  // Dark Theme Colors
  static const Color darkSurface = Color(0xFF2A2D3E);
  static const Color darkBackground = Color(0xFF212332);
  static const Color darkPrimary = Color(0xFF8A80FF);
  static const Color darkSecondary = Color(0xFFFF8FB1);
  static const Color darkTertiary = Color(0xFF80FFFF);
  static const Color darkAccent = Color(0xFFFFE663);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF8A80FF),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B95),
    Color(0xFFFF8FB1),
  ];

  AppColors({required this.context});

  bool get isDarkTheme => Theme.of(context).brightness == Brightness.dark;

  Brightness get brightness => isDarkTheme ? Brightness.dark : Brightness.light;

  Color get surfaceColor => isDarkTheme ? darkSurface : lightSurface;
  Color get onSurfaceColor => isDarkTheme ? Colors.white : Colors.black;

  Color get backgroundColor => isDarkTheme ? darkBackground : lightBackground;
  Color get onBackgroundColor => isDarkTheme ? Colors.white : Colors.black;

  Color get primaryColor => isDarkTheme ? darkPrimary : lightPrimary;
  Color get onPrimaryColor => Colors.white;

  Color get secondaryColor => isDarkTheme ? darkSecondary : lightSecondary;
  Color get onSecondaryColor => Colors.white;

  Color get tertiaryColor => isDarkTheme ? darkTertiary : lightTertiary;
  Color get onTertiaryColor => isDarkTheme ? darkBackground : Colors.black;

  Color get accentColor => isDarkTheme ? darkAccent : lightAccent;
}
