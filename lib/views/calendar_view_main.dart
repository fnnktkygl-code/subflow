import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/subscription_model.dart';

// ======================================================================
// Subscription Occurrence - Data class linking subscription to date
// ======================================================================

class SubscriptionOccurrence {
  final Subscription subscription;
  final DateTime date;

  SubscriptionOccurrence(this.subscription, this.date);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionOccurrence &&
        other.subscription.id == subscription.id &&
        other.date == date;
  }

  @override
  int get hashCode => subscription.id.hashCode ^ date.hashCode;

  @override
  String toString() {
    return 'SubscriptionOccurrence(${subscription.name}, ${DateFormat('yyyy-MM-dd').format(date)})';
  }
}

// ======================================================================
// Calendar Helpers - Pure utility functions
// ======================================================================

class CalendarHelpers {
  // Private constructor to prevent instantiation
  CalendarHelpers._();

  // =====================================================================
  // DATE CALCULATIONS
  // =====================================================================

  /// Calculate the next payment date based on subscription cycle
  static DateTime calculateNextDate(DateTime current, String cycle) {
    switch (cycle) {
      case 'Weekly':
        return current.add(const Duration(days: 7));

      case 'Monthly':
        var newMonth = current.month + 1;
        var newYear = current.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);

      case 'Yearly':
        final isLeap = current.month == 2 && current.day == 29;
        return DateTime(
          current.year + 1,
          current.month,
          isLeap ? 28 : current.day,
        );

      default:
        return DateTime.now().add(const Duration(days: 365 * 10));
    }
  }

  /// Get all upcoming subscription occurrences for the next 2 months
  static List<SubscriptionOccurrence> getUpcomingOccurrences(
      List<Subscription> subs,
      ) {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month + 2, 0);
    final occurrences = <SubscriptionOccurrence>[];

    for (final sub in subs) {
      DateTime current = sub.startDate;
      while (current.isBefore(limit)) {
        if (!current.isBefore(now) || DateUtils.isSameDay(current, now)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        DateTime next = calculateNextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  /// Calculate total amount for a specific month
  static double calculateMonthlyTotal(
      Map<DateTime, List<Subscription>> subsByDate,
      DateTime currentMonth,
      ) {
    double total = 0.0;
    subsByDate.forEach((date, subscriptions) {
      if (date.month == currentMonth.month && date.year == currentMonth.year) {
        total += subscriptions.fold(0.0, (sum, sub) => sum + sub.amount);
      }
    });
    return total;
  }

  // =====================================================================
  // AMOUNT FORMATTING
  // =====================================================================

  /// Format an amount with optional blur effect
  static String formatAmount(double amount, bool isBlurred) {
    if (isBlurred) return '••••€';
    if (amount == 0) return '0.00€';
    final isNegative = amount < 0;
    final sign = isNegative ? '−' : '+';
    return '$sign${amount.abs().toStringAsFixed(2)}€';
  }

  // =====================================================================
  // COLOR HELPERS
  // =====================================================================

  /// Get the revenue color based on theme brightness
  static Color getRevenueColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? Colors.tealAccent.shade400
        : Colors.green.shade600;
  }

  /// Get the appropriate color for an amount display
  static Color getAmountColor(double amount, ColorScheme colorScheme) {
    if (amount == 0) {
      return colorScheme.onSurface.withOpacity(0.6);
    } else if (amount < 0) {
      return colorScheme.error;
    } else {
      return getRevenueColor(colorScheme);
    }
  }

  /// Calculate heatmap opacity based on amount
  static double getHeatmapOpacity(double amount) {
    const double maxAmountForOpacity = 200.0;
    const double minOpacity = 0.12;
    const double maxOpacity = 0.6;
    if (amount == 0) return 0;
    final ratio = (amount.abs() / maxAmountForOpacity).clamp(0.0, 1.0);
    return minOpacity + (ratio * (maxOpacity - minOpacity));
  }

  // =====================================================================
  // GROUPING LOGIC
  // =====================================================================

  /// Group occurrences by time period for display
  static Map<String, List<SubscriptionOccurrence>> groupOccurrences(
      List<SubscriptionOccurrence> occurrences,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));
    final map = <String, List<SubscriptionOccurrence>>{};

    for (var occ in occurrences) {
      String key;
      if (DateUtils.isSameDay(occ.date, today)) {
        key = 'Due Today';
      } else if (!occ.date.isAfter(endOfWeek)) {
        key = 'Due this Week';
      } else if (occ.date.month == today.month) {
        key = 'Later this Month';
      } else {
        key = DateFormat('MMMM yyyy').format(occ.date);
      }
      map.putIfAbsent(key, () => []).add(occ);
    }
    return map;
  }
}