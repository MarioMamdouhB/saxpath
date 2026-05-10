import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const _fontFamilyFallback = <String>[
    'Noto Sans Arabic',
    'Segoe UI',
    'Tahoma',
    'Arial',
    'sans-serif',
  ];

  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepTeal,
      primary: AppColors.deepTeal,
      secondary: AppColors.warmGold,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: _withArabicFallback(
        Typography.material2021().black.apply(
              bodyColor: AppColors.charcoal,
              displayColor: AppColors.charcoal,
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.deepTeal,
        secondarySelectedColor: AppColors.deepTeal,
        labelStyle: const TextStyle(
          color: AppColors.charcoal,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.deepTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepTeal,
          side: const BorderSide(color: AppColors.deepTeal),
          minimumSize: const Size(0, 52),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.deepTeal,
        textColor: AppColors.charcoal,
      ),
    );
  }

  static TextTheme _withArabicFallback(TextTheme theme) {
    return theme.copyWith(
      displayLarge: _withFallback(theme.displayLarge),
      displayMedium: _withFallback(theme.displayMedium),
      displaySmall: _withFallback(theme.displaySmall),
      headlineLarge: _withFallback(theme.headlineLarge),
      headlineMedium: _withFallback(theme.headlineMedium),
      headlineSmall: _withFallback(theme.headlineSmall),
      titleLarge: _withFallback(theme.titleLarge),
      titleMedium: _withFallback(theme.titleMedium),
      titleSmall: _withFallback(theme.titleSmall),
      bodyLarge: _withFallback(theme.bodyLarge),
      bodyMedium: _withFallback(theme.bodyMedium),
      bodySmall: _withFallback(theme.bodySmall),
      labelLarge: _withFallback(theme.labelLarge),
      labelMedium: _withFallback(theme.labelMedium),
      labelSmall: _withFallback(theme.labelSmall),
    );
  }

  static TextStyle? _withFallback(TextStyle? style) {
    if (style == null) {
      return null;
    }

    return style.copyWith(fontFamilyFallback: _fontFamilyFallback);
  }
}
