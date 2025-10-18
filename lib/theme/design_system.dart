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
  // COMMON DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════

  /// Standard section decoration with gradient and border
  static BoxDecoration buildSectionDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [
          colorScheme.surface,
          colorScheme.surface.withOpacity(0.8),
        ]
            : [
          colorScheme.surface,
          colorScheme.surfaceContainerLow,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radiusXL),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 1,
      ),
    );
  }

  /// Card decoration (slightly smaller radius)
  static BoxDecoration buildCardDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [
          colorScheme.surface,
          colorScheme.surface.withOpacity(0.8),
        ]
            : [
          colorScheme.surface,
          colorScheme.surfaceContainerLow,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 1,
      ),
    );
  }
}

/// Health status colors (centralized)
class HealthColors {
  HealthColors._();

  static const Color healthy = Color(0xFF10B981);  // Emerald
  static const Color warning = Color(0xFFF59E0B);  // Amber
  static const Color danger = Color(0xFFEF4444);   // Red
}