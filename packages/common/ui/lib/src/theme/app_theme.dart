import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';

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
  static const Color _lightBase = Color(0xFFF6F7F9);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFDFDFE);
  static const Color _darkBase = Color(0xFF0E1014);
  static const Color _darkSurface = Color(0xFF151922);
  static const Color _darkCard = Color(0xFF1A202B);

  static ThemeData light({AppThemeVariant variant = AppThemeVariant.blue}) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: variant.color,
      onPrimary: Colors.white,
      secondary: variant.color.withValues(alpha: 0.9),
      onSecondary: Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: _lightSurface,
      onSurface: const Color(0xFF1B1E25),
      surfaceContainerHighest: _lightCard,
      onSurfaceVariant: const Color(0xFF5F6676),
      outline: const Color(0xFFD7DDE7),
      outlineVariant: const Color(0xFFE7EBF2),
      shadow: const Color(0x22000000),
      scrim: const Color(0x80000000),
      inverseSurface: const Color(0xFF252B37),
      onInverseSurface: Colors.white,
      inversePrimary: variant.color.withValues(alpha: 0.75),
      tertiary: const Color(0xFF6A748A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFEEF1F7),
      onTertiaryContainer: const Color(0xFF2A3040),
      surfaceTint: variant.color.withValues(alpha: 0.12),
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBase,
      textTheme: _editorialTextTheme(Brightness.light, colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: _editorialTextTheme(
          Brightness.light,
          colorScheme.onSurface,
        ).titleLarge,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: _lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        filled: true,
        fillColor: _lightSurface,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: variant.color, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      extensions: const [DesignTokens()],
    );
  }

  static ThemeData dark({
    AppThemeVariant variant = AppThemeVariant.blue,
    bool amoled = false,
  }) {
    final background = amoled ? Colors.black : _darkBase;
    final surface = amoled ? const Color(0xFF050507) : _darkSurface;
    final card = amoled ? const Color(0xFF0A0C10) : _darkCard;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: variant.color.withValues(alpha: 0.92),
      onPrimary: Colors.white,
      secondary: variant.color.withValues(alpha: 0.78),
      onSecondary: Colors.white,
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      surface: surface,
      onSurface: const Color(0xFFE8EBF3),
      surfaceContainerHighest: card,
      onSurfaceVariant: const Color(0xFFA2A9B8),
      outline: const Color(0xFF2E3543),
      outlineVariant: const Color(0xFF252B36),
      shadow: const Color(0x55000000),
      scrim: const Color(0x99000000),
      inverseSurface: const Color(0xFFE5E8EF),
      onInverseSurface: const Color(0xFF171B25),
      inversePrimary: variant.color,
      tertiary: const Color(0xFF8E97AD),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF242B3A),
      onTertiaryContainer: const Color(0xFFD5DAE8),
      surfaceTint: variant.color.withValues(alpha: 0.12),
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _editorialTextTheme(Brightness.dark, colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: _editorialTextTheme(
          Brightness.dark,
          colorScheme.onSurface,
        ).titleLarge,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: variant.color, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      extensions: const [DesignTokens()],
    );
  }

  static TextTheme _editorialTextTheme(Brightness brightness, Color baseColor) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: baseColor,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: baseColor,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: baseColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: baseColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: baseColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: baseColor.withValues(alpha: 0.92),
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: baseColor.withValues(alpha: 0.72),
      ),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
