// lib/utils/home_helpers.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for home screen operations
class HomeHelpers {
  // Private constructor to prevent instantiation
  HomeHelpers._();

  // =======================================================================
  // GREETINGS & MOTIVATION
  // =======================================================================

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "gm ☀️";
    if (hour >= 12 && hour < 17) return "hey there 👋";
    if (hour >= 17 && hour < 22) return "good vibes 🌙";
    return "night owl 🦉";
  }

  static String getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "let's save some money today";
    if (hour >= 12 && hour < 17) return "crushing your goals";
    if (hour >= 17 && hour < 22) return "you're doing great btw";
    return "rest well, champ";
  }

  // =======================================================================
  // CATEGORY STYLING (MODERN)
  // =======================================================================

  /// Defines the master map for all category styles.
  static Map<String, Map<String, dynamic>> getCategoryMap() {
    return {
      'Home': {'color': const Color(0xFFEC4899), 'icon': Icons.home_rounded},
      'Utilities': {'color': const Color(0xFF3B82F6), 'icon': Icons.bolt_rounded},
      'Telecom': {'color': const Color(0xFF8B5CF6), 'icon': Icons.phone_iphone_rounded},
      'Media & Entertainment': {'color': const Color(0xFFF59E0B), 'icon': Icons.play_circle_outline_rounded},
      'Health & Wellness': {'color': const Color(0xFF10B981), 'icon': Icons.favorite_rounded},
      'Transport': {'color': const Color(0xFF06B6D4), 'icon': Icons.directions_car_rounded},
      'Insurance': {'color': const Color(0xFF6366F1), 'icon': Icons.shield_rounded},
      'Financial': {'color': const Color(0xFF22C55E), 'icon': Icons.account_balance_rounded},
      'Shopping': {'color': const Color(0xFFD946EF), 'icon': Icons.shopping_bag_rounded},
      'Gaming': {'color': const Color(0xFF64748B), 'icon': Icons.sports_esports_rounded},
      'Software': {'color': const Color(0xFF0EA5E9), 'icon': Icons.code_rounded},
      'General': {'color': const Color(0xFF78716C), 'icon': Icons.category_rounded},
    };
  }

  /// Get color for a specific category from the modern palette.
  static Color getCategoryColor(String category) {
    return getCategoryMap()[category]?['color'] as Color? ?? const Color(0xFF78716C);
  }

  /// Get icon for a specific category from the modern palette.
  static IconData getCategoryIcon(String category) {
    final iconMap = getCategoryMap(); // No BuildContext needed
    return iconMap[category]?['icon'] as IconData? ?? Icons.category_rounded;
  }

  // =======================================================================
  // CHART & UI HELPERS
  // =======================================================================

  static List<Color> generateChartColors(BuildContext context) {
    return [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
    ];
  }

  // =======================================================================
  // DATE & TIME HELPERS
  // =======================================================================

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference > 1) return 'In $difference days';
    return DateFormat('EEE, d MMM').format(date);
  }

  // =======================================================================
  // SMART TIPS & INSIGHTS
  // =======================================================================
}