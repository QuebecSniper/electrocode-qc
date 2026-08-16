import 'package:flutter/material.dart';

class ElectroTheme {
  static const navy = Color(0xFF0B1F3A);
  static const amber = Color(0xFFE6B325);
  static const paper = Color(0xFFF6F3EA);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        secondary: amber,
        surface: paper,
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: navy,
      ),
    );
  }
}
