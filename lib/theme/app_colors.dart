import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A28);
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFF00D4AA);
  static const Color bg = Color(0xFF0D0D1A);
  static const Color card = Color(0xFF16213E);
  static const Color cardLight = Color(0xFF1E2A45);
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textMuted = Color(0xFF8A9BB8);
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB347);
  static const Color danger = Color(0xFFFF4D6D);
  static const Color purple = Color(0xFF7B5EA7);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, Color(0xFF9B72CF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00A896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
