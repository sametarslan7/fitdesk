import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B)),
      scaffoldBackgroundColor: const Color(0xFFF6F8F7),
    );
  }
}
