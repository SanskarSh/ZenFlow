import 'package:flutter/material.dart';
import 'package:todo/src/core/constant/color.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) {
    return _buildTheme(context, false);
  }

  static ThemeData darkTheme(BuildContext context) {
    return _buildTheme(context, true);
  }

  static ThemeData _buildTheme(BuildContext context, bool isDark) {
    final colors = AppColors(context: context);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: colors.surfaceColor,
        onSurface: colors.onSurfaceColor,
        primary: colors.primaryColor,
        onPrimary: colors.onPrimaryColor,
        secondary: colors.secondaryColor,
        onSecondary: colors.onSecondaryColor,
        tertiary: colors.tertiaryColor,
        onTertiary: colors.onTertiaryColor,
        error: const Color(0xFFFF5252),
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colors.onSurfaceColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: colors.onSurfaceColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colors.onSurfaceColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colors.onSurfaceColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: colors.onPrimaryColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceColor,
        foregroundColor: colors.onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      scaffoldBackgroundColor: colors.backgroundColor,
      cardTheme: CardTheme(
        color: colors.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryColor,
          foregroundColor: colors.onPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
