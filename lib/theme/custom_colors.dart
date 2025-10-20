// lib/theme/custom_colors.dart

import 'package:flutter/material.dart';

/// A class to hold custom semantic colors that are not part of the standard ColorScheme.
class CustomColors extends ThemeExtension<CustomColors> {
  final List<Color>? successGradient;
  final List<Color>? errorGradient;
  final Map<String, Color>? categoryColors;
  final Color? heatmapExpense;
  final Color? heatmapIncome;

  // ✅ ADDED: Health status colors, now theme-aware
  final Color? healthy;
  final Color? warning;
  final Color? danger;

  const CustomColors({
    required this.successGradient,
    required this.errorGradient,
    required this.categoryColors,
    required this.heatmapExpense,
    required this.heatmapIncome,
    // ✅ ADDED: Add new health properties to the constructor
    required this.healthy,
    required this.warning,
    required this.danger,
  });

  @override
  ThemeExtension<CustomColors> copyWith({
    List<Color>? successGradient,
    List<Color>? errorGradient,
    Map<String, Color>? categoryColors,
    Color? heatmapExpense,
    Color? heatmapIncome,
    // ✅ ADDED
    Color? healthy,
    Color? warning,
    Color? danger,
  }) {
    return CustomColors(
      successGradient: successGradient ?? this.successGradient,
      errorGradient: errorGradient ?? this.errorGradient,
      categoryColors: categoryColors ?? this.categoryColors,
      heatmapExpense: heatmapExpense ?? this.heatmapExpense,
      heatmapIncome: heatmapIncome ?? this.heatmapIncome,
      // ✅ ADDED
      healthy: healthy ?? this.healthy,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    // For simplicity, we'll just switch colors at the halfway point during theme transitions.
    // A more complex lerp could be implemented here if needed.
    return t < 0.5 ? this : other;
  }
}