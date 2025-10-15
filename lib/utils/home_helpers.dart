import 'package:flutter/material.dart';

/// Utility class for home screen operations
class HomeHelpers {
  // Private constructor to prevent instantiation
  HomeHelpers._();

  /// Generate theme-aware chart colors with vibrant palette
  static List<Color> generateChartColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final baseColors = [
      colorScheme.primary,           // Theme primary
      colorScheme.secondary,         // Theme secondary
      colorScheme.tertiary,          // Theme tertiary
      const Color(0xFFFA709A),       // Coral pink
      const Color(0xFFF093FB),       // Vibrant purple
      const Color(0xFF43E97B),       // Fresh green
      const Color(0xFFFFC107),       // Sunny yellow
      const Color(0xFF667EEA),       // Soft blue-purple
      const Color(0xFFFF6B6B),       // Warm red
      const Color(0xFF4ECDC4),       // Turquoise
      const Color(0xFFFFBE0B),       // Golden yellow
      const Color(0xFFFB5607),       // Vibrant orange
    ];

    // Adjust opacity for light/dark mode
    return baseColors
        .map((c) => isDark ? c : c.withOpacity(0.95))
        .toList();
  }

  /// Get color for a specific category (consistent colors per category)
  static Color getCategoryColor(String category, BuildContext context) {
    final colors = generateChartColors(context);
    final hash = category.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "gm ☀️";
    } else if (hour >= 12 && hour < 17) {
      return "hey there 👋";
    } else if (hour >= 17 && hour < 22) {
      return "good vibes 🌙";
    } else {
      return "night owl 🦉";
    }
  }

  /// Get motivational subtitle based on time of day
  static String getSubtitle() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "let's save some money today";
    } else if (hour >= 12 && hour < 17) {
      return "crushing your goals";
    } else if (hour >= 17 && hour < 22) {
      return "you're doing great btw";
    } else {
      return "rest well, champ";
    }
  }

  /// Get time-based emoji
  static String getTimeEmoji() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) return "☀️";
    if (hour >= 12 && hour < 17) return "👋";
    if (hour >= 17 && hour < 22) return "🌙";
    return "🦉";
  }

  /// Calculate trend percentage between current and previous values
  static double calculateTrend(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Format trend as string with sign
  static String formatTrend(double trend) {
    final sign = trend >= 0 ? '+' : '';
    return '$sign${trend.toStringAsFixed(1)}%';
  }

  /// Check if trend is positive (bad for spending)
  static bool isTrendNegative(double trend) {
    return trend > 0; // Positive trend = spending more = bad
  }

  /// Format currency with euro symbol
  static String formatCurrency(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return '€${amount.toStringAsFixed(2)}';
    }
    return '€${amount.toStringAsFixed(0)}';
  }

  /// Format large numbers with K suffix
  static String formatLargeNumber(double number) {
    if (number >= 1000) {
      return '€${(number / 1000).toStringAsFixed(1)}K';
    }
    return formatCurrency(number, showDecimals: false);
  }

  /// Calculate yearly cost from monthly
  static double calculateYearlyCost(double monthlyCost) {
    return monthlyCost * 12;
  }

  /// Calculate monthly cost from yearly
  static double calculateMonthlyCost(double yearlyCost) {
    return yearlyCost / 12;
  }

  /// Get relative date string (Today, Tomorrow, In X days)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference < 7) return 'In $difference days';
    if (difference < -1 && difference > -7) return '${difference.abs()} days ago';

    // Format as date
    return '${date.day}/${date.month}';
  }

  /// Get month name from number
  static String getMonthName(int month, {bool short = false}) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    if (month < 1 || month > 12) return '';
    return short ? shortMonths[month - 1] : months[month - 1];
  }

  /// Generate smart tip based on spending data
  static String? generateSmartTip(Map<String, double> categorySpending) {
    if (categorySpending.isEmpty) return null;

    // Find most expensive category
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sorted.first;
    final potentialSavings = topCategory.value * 0.3; // Assume 30% savings possible

    // Don't show tip if savings are too small
    if (potentialSavings < 10) return null;

    // Generate contextual tips based on category
    final tips = _getCategorySpecificTips(topCategory.key, potentialSavings);

    return tips.isNotEmpty ? tips.first : null;
  }

  /// Get category-specific saving tips
  static List<String> _getCategorySpecificTips(String category, double savings) {
    final categoryLower = category.toLowerCase();
    final savingsStr = savings.toStringAsFixed(0);

    if (categoryLower.contains('streaming') ||
        categoryLower.contains('entertainment') ||
        categoryLower.contains('video')) {
      return [
        "Your $category spending is higher than average. You could save €$savingsStr/month by bundling services or sharing family plans!",
        "Consider rotating streaming services monthly instead of keeping them all active. Save €$savingsStr!",
      ];
    }

    if (categoryLower.contains('music') || categoryLower.contains('audio')) {
      return [
        "Multiple music services? You could save €$savingsStr/month by sticking to just one platform.",
      ];
    }

    if (categoryLower.contains('cloud') ||
        categoryLower.contains('storage') ||
        categoryLower.contains('backup')) {
      return [
        "Your $category costs add up! Consolidate to one provider and save €$savingsStr/month.",
      ];
    }

    if (categoryLower.contains('fitness') ||
        categoryLower.contains('health') ||
        categoryLower.contains('gym')) {
      return [
        "Multiple fitness subscriptions? Pick your favorite and save €$savingsStr/month!",
      ];
    }

    if (categoryLower.contains('productivity') ||
        categoryLower.contains('software') ||
        categoryLower.contains('tools')) {
      return [
        "Your $category subscriptions could be optimized. Look for bundle deals to save €$savingsStr/month!",
      ];
    }

    if (categoryLower.contains('gaming') || categoryLower.contains('game')) {
      return [
        "Gaming subscriptions piling up? You could save €$savingsStr/month by rotating services seasonally.",
      ];
    }

    if (categoryLower.contains('news') ||
        categoryLower.contains('magazine') ||
        categoryLower.contains('media')) {
      return [
        "Consider free alternatives or library access for news & media. Save €$savingsStr/month!",
      ];
    }

    // Generic tip
    return [
      "Your $category spending is higher than average. You could save €$savingsStr/month by exploring alternatives!",
    ];
  }

  /// Calculate percentage of goal reached
  static double calculateGoalProgress(double current, double goal) {
    if (goal <= 0) return 0.0;
    return (current / goal).clamp(0.0, 1.0);
  }

  /// Check if goal is met
  static bool isGoalMet(double current, double goal) {
    return current <= goal;
  }

  /// Get goal status message
  static String getGoalStatusMessage(double current, double goal) {
    if (isGoalMet(current, goal)) {
      return 'goal achieved! 🎉';
    }

    final progress = calculateGoalProgress(current, goal);
    return '${(progress * 100).toStringAsFixed(0)}% of goal';
  }

  /// Calculate days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    return targetDay.difference(today).inDays;
  }

  /// Check if date is soon (within 3 days)
  static bool isSoon(DateTime date) {
    final days = daysUntil(date);
    return days >= 0 && days <= 3;
  }

  /// Get next billing date for a subscription
  static DateTime getNextBillingDate(DateTime lastBillingDate, String cycle) {
    final cycleLower = cycle.toLowerCase();

    if (cycleLower.contains('month')) {
      return DateTime(
        lastBillingDate.year,
        lastBillingDate.month + 1,
        lastBillingDate.day,
      );
    }

    if (cycleLower.contains('year') || cycleLower.contains('annual')) {
      return DateTime(
        lastBillingDate.year + 1,
        lastBillingDate.month,
        lastBillingDate.day,
      );
    }

    if (cycleLower.contains('week')) {
      return lastBillingDate.add(const Duration(days: 7));
    }

    // Default to monthly
    return DateTime(
      lastBillingDate.year,
      lastBillingDate.month + 1,
      lastBillingDate.day,
    );
  }

  /// Sort subscriptions by next billing date
  static List<T> sortByNextBilling<T>(
      List<T> items,
      DateTime Function(T) getDate,
      ) {
    final sorted = List<T>.from(items);
    sorted.sort((a, b) => getDate(a).compareTo(getDate(b)));
    return sorted;
  }

  /// Get icon for category
  static IconData getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('streaming') || categoryLower.contains('video')) {
      return Icons.play_circle_outline_rounded;
    }
    if (categoryLower.contains('music') || categoryLower.contains('audio')) {
      return Icons.music_note_rounded;
    }
    if (categoryLower.contains('cloud') || categoryLower.contains('storage')) {
      return Icons.cloud_outlined;
    }
    if (categoryLower.contains('fitness') || categoryLower.contains('health')) {
      return Icons.fitness_center_rounded;
    }
    if (categoryLower.contains('gaming') || categoryLower.contains('game')) {
      return Icons.sports_esports_rounded;
    }
    if (categoryLower.contains('news') || categoryLower.contains('magazine')) {
      return Icons.article_outlined;
    }
    if (categoryLower.contains('productivity') || categoryLower.contains('software')) {
      return Icons.work_outline_rounded;
    }
    if (categoryLower.contains('food') || categoryLower.contains('delivery')) {
      return Icons.restaurant_outlined;
    }
    if (categoryLower.contains('education') || categoryLower.contains('learning')) {
      return Icons.school_outlined;
    }

    return Icons.subscriptions_rounded;
  }

  /// Generate motivational message based on progress
  static String getMotivationalMessage(double current, double goal, int level) {
    final progress = calculateGoalProgress(current, goal);

    if (isGoalMet(current, goal)) {
      return [
        "Absolutely crushing it! 🔥",
        "You're a savings legend! 🏆",
        "Goal smashed! Keep it up! 💪",
        "Financial wizard right here! 🧙‍♂️",
      ][level % 4];
    }

    if (progress >= 0.9) {
      return "So close! You got this! 💪";
    }

    if (progress >= 0.7) {
      return "Great progress! Keep going! 🚀";
    }

    if (progress >= 0.5) {
      return "Halfway there! Stay strong! ⚡";
    }

    return "Every step counts! 🌟";
  }

  /// Calculate average subscription cost
  static double calculateAverageCost(List<double> costs) {
    if (costs.isEmpty) return 0.0;
    return costs.reduce((a, b) => a + b) / costs.length;
  }

  /// Find most expensive subscription
  static T? findMostExpensive<T>(
      List<T> items,
      double Function(T) getCost,
      ) {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => getCost(a) > getCost(b) ? a : b);
  }

  /// Calculate total savings if goal is met
  static double calculatePotentialSavings(double current, double goal) {
    if (current <= goal) return 0.0;
    return current - goal;
  }

  /// Format duration in human-readable form
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return 'now';
  }
}