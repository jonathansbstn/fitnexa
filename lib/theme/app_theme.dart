import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Shared input/snack decoration ──────────────────────────────────────
  static InputDecorationTheme _inputTheme(Color fill, Color border, Color hint) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: hint, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  static SnackBarThemeData get _snackTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: AppColors.success,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );

  // ── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          // card background
          surface: Color(0xFF16213E),
          // card light / secondary surfaces
          surfaceContainerHighest: Color(0xFF1E2A45),
          // text on surfaces
          onSurface: Color(0xFFF0F0F0),
          // muted text
          onSurfaceVariant: Color(0xFF8A9BB8),
          // dividers
          outlineVariant: Color(0x0DFFFFFF),
        ),
        textTheme:
            GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: const Color(0xFFF0F0F0),
          displayColor: const Color(0xFFF0F0F0),
        ),
        inputDecorationTheme: _inputTheme(
          const Color(0xFF1E2A45),
          const Color(0x14FFFFFF),
          const Color(0xFF8A9BB8),
        ),
        snackBarTheme: _snackTheme,
      );

  // ── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: Colors.white,
          surfaceContainerHighest: Color(0xFFEEF0F4),
          onSurface: Color(0xFF1A1A2E),
          onSurfaceVariant: Color(0xFF6B7280),
          outlineVariant: Color(0x14000000),
        ),
        textTheme:
            GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: const Color(0xFF1A1A2E),
          displayColor: const Color(0xFF1A1A2E),
        ),
        inputDecorationTheme: _inputTheme(
          const Color(0xFFEEF0F4),
          const Color(0x14000000),
          const Color(0xFF9CA3AF),
        ),
        snackBarTheme: _snackTheme,
      );
}
