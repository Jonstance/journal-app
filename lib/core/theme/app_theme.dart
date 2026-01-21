import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData light(double warmthShift) {
    final base = ThemeData.light(useMaterial3: true);
    final background = Color.lerp(AppColors.offWhite, AppColors.mist, warmthShift) ?? AppColors.offWhite;
    final surface = Color.lerp(Colors.white, AppColors.mist, warmthShift) ?? Colors.white;
    final primary = Color.lerp(AppColors.navy, AppColors.teal, warmthShift) ?? AppColors.navy;
    final accent = Color.lerp(AppColors.amber, AppColors.coral, warmthShift) ?? AppColors.amber;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        onSurface: AppColors.ink,
        onBackground: AppColors.ink,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(AppColors.ink),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      dividerColor: AppColors.mist,
    );
  }

  static ThemeData dark(double warmthShift) {
    final base = ThemeData.dark(useMaterial3: true);
    final background = Color.lerp(AppColors.charcoal, AppColors.deepMist, warmthShift) ?? AppColors.charcoal;
    final surface = Color.lerp(const Color(0xFF15191C), const Color(0xFF1C2226), warmthShift) ?? const Color(0xFF15191C);
    final primary = Color.lerp(AppColors.teal, AppColors.navy, warmthShift) ?? AppColors.teal;
    final accent = Color.lerp(AppColors.coral, AppColors.amber, warmthShift) ?? AppColors.coral;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        onSurface: const Color(0xFFE6E1D9),
        onBackground: const Color(0xFFE6E1D9),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(const Color(0xFFE6E1D9)),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      dividerColor: const Color(0xFF2A2F33),
    );
  }

  static TextTheme _textTheme(Color color) {
    final serif = GoogleFonts.loraTextTheme();
    final sans = GoogleFonts.soraTextTheme();

    return serif.copyWith(
      displayLarge: sans.displayLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      displayMedium: sans.displayMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      displaySmall: sans.displaySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineLarge: sans.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineMedium: sans.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineSmall: sans.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleLarge: sans.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleMedium: sans.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleSmall: sans.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      bodyLarge: serif.bodyLarge?.copyWith(color: color, height: 1.6),
      bodyMedium: serif.bodyMedium?.copyWith(color: color, height: 1.6),
      bodySmall: serif.bodySmall?.copyWith(color: color.withOpacity(0.8), height: 1.5),
      labelLarge: sans.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      labelMedium: sans.labelMedium?.copyWith(color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
      labelSmall: sans.labelSmall?.copyWith(color: color.withOpacity(0.7), fontWeight: FontWeight.w600),
    );
  }
}
