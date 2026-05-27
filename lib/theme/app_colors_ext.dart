import 'package:flutter/material.dart';

/// BuildContext extension to resolve theme-aware colors.
/// Use these instead of hardcoded AppColors.* constants so that
/// dark-mode / light-mode switching works automatically.
extension AppColorsExt on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Main background color (Scaffold)
  Color get appBg => Theme.of(this).scaffoldBackgroundColor;

  /// Card / surface background
  Color get appCard => Theme.of(this).colorScheme.surface;

  /// Secondary card / input fill background
  Color get appCardLight =>
      Theme.of(this).colorScheme.surfaceContainerHighest;

  /// Primary text color
  Color get appTextPrimary => Theme.of(this).colorScheme.onSurface;

  /// Muted / secondary text color
  Color get appTextMuted => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Subtle divider / border color
  Color get appDivider => Theme.of(this).colorScheme.outlineVariant;
}
