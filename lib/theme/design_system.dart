// lib/theme/design_system.dart

import 'package:flutter/material.dart';

/// Centralized design system constants following Material 3 guidelines
class DesignSystem {
  // Private constructor to prevent instantiation
  DesignSystem._();

  // ═══════════════════════════════════════════════════════════════════════
  // SPACING SCALE
  // ═══════════════════════════════════════════════════════════════════════
  static const double spacing1 = 2.0;   // Hairline gaps
  static const double spacing2 = 4.0;   // Micro gaps
  static const double spacing3 = 6.0;   // Tiny gaps
  static const double spacing4 = 8.0;   // Small gaps
  static const double spacing6 = 12.0;  // Standard gaps
  static const double spacing8 = 16.0;  // Standard padding
  static const double spacing10 = 20.0; // Content padding
  static const double spacing12 = 24.0; // Section padding
  static const double spacing16 = 32.0; // Large gaps
  static const double spacing20 = 40.0; // Extra large gaps

  // ═══════════════════════════════════════════════════════════════════════
  // BORDER RADIUS SCALE
  // ═══════════════════════════════════════════════════════════════════════
  static const double radiusSmall = 12.0;  // Small buttons, pills
  static const double radiusMedium = 16.0; // Input fields, cards
  static const double radiusLarge = 20.0;  // Larger cards, banners
  static const double radiusXL = 24.0;     // Main container sections
  static const double radiusXXL = 28.0;    // Bottom sheets, main cards
  static const double radiusFull = 9999.0;  // Fully rounded pills/badges


  // ═══════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════════════
  static const double iconXSmall = 14.0;  // Labels, badges
  static const double iconSmall = 16.0;   // Small buttons
  static const double iconMedium = 20.0;  // Standard buttons
  static const double iconLarge = 24.0;   // Section headers
  static const double iconXLarge = 28.0;  // Main icons
  static const double iconCard = 48.0;    // Card icons

  // ═══════════════════════════════════════════════════════════════════════
  // TOUCH TARGETS (Accessibility)
  // ═══════════════════════════════════════════════════════════════════════
  static const double minTouchTarget = 44.0;

  // ═══════════════════════════════════════════════════════════════════════
  // COMMON DECORATIONS & JAPANDI SURFACES
  // ═══════════════════════════════════════════════════════════════════════

  /// Standard section decoration with Japandi organic warmth and subtle border
  static BoxDecoration buildSectionDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? colorScheme.surface : colorScheme.surface,
      borderRadius: BorderRadius.circular(radiusXL),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.25)
              : const Color(0xFF20201E).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Card decoration with tactile Japandi simplicity
  static BoxDecoration buildCardDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? colorScheme.surface : colorScheme.surface,
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.75),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF20201E).withValues(alpha: 0.03),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// Health status colors (Japandi Botanical & Earthy Accents)
class HealthColors {
  HealthColors._();

  static const Color healthy = Color(0xFF477A56);  // Deep Matcha Green
  static const Color warning = Color(0xFFC4823F);  // Warm Yuzu / Golden Amber
  static const Color danger = Color(0xFFB84E3A);   // Japanese Akane Red Ochre
}