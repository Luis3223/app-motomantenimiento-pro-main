import 'package:flutter/material.dart';

class AppColors {
  static const strongRed = Color(0xFFE50914);
  static const darkRed = Color(0xFF9B000E);
  static const matteBlack = Color(0xFF121212);
  static const surfaceMatte = Color(0xFF1E1E1E);
  static const cardMatte = Color(0xFF252525);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const borderGrey = Color(0xFF2D2D2D);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.strongRed,
      brightness: Brightness.dark,
      primary: AppColors.strongRed,
      surface: AppColors.surfaceMatte,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.matteBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.strongRed,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardMatte,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardMatte,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.strongRed, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.strongRed,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceMatte,
      indicatorColor: AppColors.strongRed.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.strongRed,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(color: AppColors.textSecondary, fontSize: 12);
      }),
    ),
  );
}
