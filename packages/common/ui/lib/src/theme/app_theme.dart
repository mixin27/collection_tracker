import 'package:flutter/material.dart';

enum AppThemeVariant {
  blue(Color(0xFF2196F3), 'Blue'),
  purple(Color(0xFF9C27B0), 'Purple'),
  green(Color(0xFF4CAF50), 'Green'),
  orange(Color(0xFFFF9800), 'Orange'),
  rose(Color(0xFFE91E63), 'Rose');

  final Color color;
  final String label;
  const AppThemeVariant(this.color, this.label);
}

class AppTheme {
  static ThemeData light({AppThemeVariant variant = AppThemeVariant.blue}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: variant.color,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  static ThemeData dark({
    AppThemeVariant variant = AppThemeVariant.blue,
    bool amoled = false,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: variant.color,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: amoled
          ? baseScheme.copyWith(surface: Colors.black, onSurface: Colors.white)
          : baseScheme,
      scaffoldBackgroundColor: amoled ? Colors.black : null,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: amoled ? Colors.black : null,
      ),
      cardTheme: CardThemeData(
        elevation: amoled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: amoled ? BorderSide(color: Colors.grey[900]!) : BorderSide.none,
        ),
        color: amoled ? Colors.grey[950] : null,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: amoled ? Colors.grey[950] : null,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }
}
