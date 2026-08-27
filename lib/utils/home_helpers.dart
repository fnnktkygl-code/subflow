// lib/utils/home_helpers.dart (Enhanced greeting section)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for home screen operations
class HomeHelpers {
  HomeHelpers._();

  static final _random = Random();

  // =======================================================================
  // ENHANCED GREETINGS & MOTIVATION
  // =======================================================================

  /// Returns a time-appropriate greeting with context
  static String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    // Weekend vibes (Saturday = 6, Sunday = 7)
    if (dayOfWeek >= 6) {
      final isSaturday = dayOfWeek == 6;

      if (hour >= 5 && hour < 12) return "weekend mode 🌅";
      if (hour >= 12 && hour < 17) {
        return isSaturday ? "chill saturday vibes ✨" : "sunday funday ✨";
      }
      if (hour >= 17 && hour < 22) return "weekend nights 🌙";
      return "late night thoughts 💭";
    }

    // Weekday greetings
    if (hour >= 5 && hour < 12) {
      final morningGreets = ["rise & grind 🔥", "morning energy ☀️", "fresh start 🌱"];
      return morningGreets[_random.nextInt(morningGreets.length)];
    }
    if (hour >= 12 && hour < 17) {
      final afternoonGreets = ["main character energy ✨", "afternoon hustle 💪", "halfway there 🎯"];
      return afternoonGreets[_random.nextInt(afternoonGreets.length)];
    }
    if (hour >= 17 && hour < 22) {
      final eveningGreets = ["vibe check 🌙", "evening wind-down 🌆", "reflect & relax 🧘"];
      return eveningGreets[_random.nextInt(eveningGreets.length)];
    }
    return "night owl 🦉";
  }

  /// Returns contextual subtitle based on user's spending behavior
  static String getSubtitle({
    double? spendingRatio, // spending/income ratio
    int? daysUntilNextPayment,
    bool? isOverBudget,
  }) {
    final hour = DateTime.now().hour;

    // Priority: Show contextual messages first
    if (isOverBudget == true) {
      return "maybe time to review your subs?";
    }

    if (spendingRatio != null && spendingRatio > 0.8) {
      return "you're spending ${(spendingRatio * 100).toInt()}% of income 👀";
    }

    if (daysUntilNextPayment != null && daysUntilNextPayment <= 3) {
      return "payment incoming in $daysUntilNextPayment days";
    }

    // Fallback to time-based messages
    const morningMessages = [
      "let's get this bread.",
      "manifesting financial wins.",
      "your budget is looking good.",
      "starting strong today."
    ];
    const afternoonMessages = [
      "pov: you're crushing your goals.",
      "stay focused, no cap.",
      "consistency is key 🔑",
      "track, save, thrive."
    ];
    const eveningMessages = [
      "you're doing great, btw.",
      "today's spending? not bad.",
      "planning tomorrow's wins.",
      "reflect on today's choices."
    ];
    const nightMessages = [
      "rest well, champ.",
      "tomorrow's another chance.",
      "your budget is safe.",
      "goodnight, saver 😴"
    ];

    if (hour >= 5 && hour < 12) {
      return morningMessages[_random.nextInt(morningMessages.length)];
    }
    if (hour >= 12 && hour < 17) {
      return afternoonMessages[_random.nextInt(afternoonMessages.length)];
    }
    if (hour >= 17 && hour < 22) {
      return eveningMessages[_random.nextInt(eveningMessages.length)];
    }
    return nightMessages[_random.nextInt(nightMessages.length)];
  }

  // =======================================================================
  // CATEGORY STYLING (JAPANDI EARTH & BOTANICAL PALETTE)
  // =======================================================================

  static Map<String, Map<String, dynamic>> getCategoryMap() {
    return {
      'Home': {'color': const Color(0xFFB87D56), 'icon': Icons.home_rounded},                   // Terracotta Clay
      'Utilities': {'color': const Color(0xFFC4823F), 'icon': Icons.bolt_rounded},              // Yuzu Amber
      'Telecom': {'color': const Color(0xFF6B7F8E), 'icon': Icons.phone_iphone_rounded},        // Aizome Indigo
      'Media & Entertainment': {'color': const Color(0xFF9E6B55), 'icon': Icons.play_circle_outline_rounded}, // Sandalwood
      'Health & Wellness': {'color': const Color(0xFF477A56), 'icon': Icons.favorite_rounded},  // Matcha Green
      'Transport': {'color': const Color(0xFF5A7B88), 'icon': Icons.directions_car_rounded},    // River Slate
      'Insurance': {'color': const Color(0xFF4A5844), 'icon': Icons.shield_rounded},            // Deep Cedar
      'Financial': {'color': const Color(0xFF3B4D3C), 'icon': Icons.account_balance_rounded},    // Kuro-Matsu
      'Shopping': {'color': const Color(0xFFC49A6C), 'icon': Icons.shopping_bag_rounded},       // Hinoki Warm Wood
      'Gaming': {'color': const Color(0xFF7A6B88), 'icon': Icons.sports_esports_rounded},       // Muted Plum / Wisteria
      'Software': {'color': const Color(0xFF5F8278), 'icon': Icons.code_rounded},               // Bamboo Sage
      'General': {'color': const Color(0xFF8C867A), 'icon': Icons.category_rounded},            // Tatami Ash
    };
  }

  static Color getCategoryColor(String category) {
    return getCategoryMap()[category]?['color'] as Color? ?? const Color(0xFF8C867A);
  }

  static IconData getCategoryIcon(String category) {
    final iconMap = getCategoryMap();
    return iconMap[category]?['icon'] as IconData? ?? Icons.category_rounded;
  }

  // =======================================================================
  // CHART & UI HELPERS (JAPANDI HARMONY)
  // =======================================================================

  static List<Color> generateChartColors(BuildContext context) {
    return [
      const Color(0xFF477A56), // Matcha Green
      const Color(0xFFB87D56), // Terracotta
      const Color(0xFF6B7F8E), // Aizome Indigo
      const Color(0xFFC4823F), // Yuzu Amber
      const Color(0xFF5F8278), // Bamboo Sage
      const Color(0xFFC49A6C), // Hinoki Ochre
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
}