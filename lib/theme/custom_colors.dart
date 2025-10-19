// lib/theme/custom_colors.dart

import 'package:flutter/material.dart';

/// A class to hold custom semantic colors that are not part of the standard ColorScheme.
class CustomColors extends ThemeExtension<CustomColors> {
  final List<Color>? successGradient;
  final List<Color>? errorGradient;
  final Map<String, Color>? categoryColors;
  // ✅ ADDED: New properties for our theme-aware heatmap
  final Color? heatmapExpense;
  final Color? heatmapIncome;


  const CustomColors({
    required this.successGradient,
    required this.errorGradient,
    required this.categoryColors,
    // ✅ ADDED: Add new properties to the constructor
    required this.heatmapExpense,
    required this.heatmapIncome,
  });

  @override
  ThemeExtension<CustomColors> copyWith({
    List<Color>? successGradient,
    List<Color>? errorGradient,
    Map<String, Color>? categoryColors,
    // ✅ ADDED
    Color? heatmapExpense,
    Color? heatmapIncome,
  }) {
    return CustomColors(
      successGradient: successGradient ?? this.successGradient,
      errorGradient: errorGradient ?? this.errorGradient,
      categoryColors: categoryColors ?? this.categoryColors,
      // ✅ ADDED
      heatmapExpense: heatmapExpense ?? this.heatmapExpense,
      heatmapIncome: heatmapIncome ?? this.heatmapIncome,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    // For simplicity, we'll just switch colors at the halfway point during theme transitions.
    return t < 0.5 ? this : other;
  }
}
