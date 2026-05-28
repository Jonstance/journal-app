import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData light(double warmthShift) {
    final base = ThemeData.light(useMaterial3: true);
    final background = Color.lerp(AppColors.cream, AppColors.mist, warmthShift) ?? AppColors.cream;
    final surface = Color.lerp(const Color(0xFFFAF6F0), AppColors.mist, warmthShift) ?? const Color(0xFFFAF6F0);
    final primary = Color.lerp(AppColors.velvet, AppColors.velvetLight, warmthShift) ?? AppColors.velvet;
    final accent = Color.lerp(AppColors.amber, AppColors.coral, warmthShift) ?? AppColors.amber;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: AppColors.ink,
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
    final background = Color.lerp(AppColors.dusk, AppColors.deepMist, warmthShift) ?? AppColors.dusk;
    final surface = Color.lerp(const Color(0xFF261520), const Color(0xFF2A1E24), warmthShift) ?? const Color(0xFF261520);
    final primary = Color.lerp(AppColors.velvetLight, AppColors.velvet, warmthShift) ?? AppColors.velvetLight;
    final accent = Color.lerp(AppColors.coral, AppColors.amber, warmthShift) ?? AppColors.coral;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: AppColors.cream,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(AppColors.cream),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      dividerColor: const Color(0xFF3A2030),
    );
  }

  static TextStyle brandMono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
    Color? color,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );

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
      bodySmall: serif.bodySmall?.copyWith(color: color.withValues(alpha: 0.8), height: 1.5),
      labelLarge: sans.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      labelMedium: sans.labelMedium?.copyWith(color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
      labelSmall: sans.labelSmall?.copyWith(color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
    );
  }
}
