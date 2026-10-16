import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE8590C);
  static const primaryDark = Color(0xFFC2410C);
  static const background = Color(0xFFFFF8F3);
  static const card = Colors.white;
  static const textMuted = Color(0xFF6B7280);
  static const star = Color(0xFFF59E0B);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: AppColors.background,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
