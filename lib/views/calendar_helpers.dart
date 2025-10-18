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
      // Return a distant future date for unknown cycles
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
        // Include if it's today or in the future
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

  // =====================================================================
  // AMOUNT FORMATTING & COLOR
  // =====================================================================

  /// Format an amount with optional blur effect and currency symbol from locale.
  static String formatAmount(double amount, bool isBlurred, BuildContext context) {
    if (isBlurred) return '••••';

    final format = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR', // You can change this or make it dynamic
    );

    if (amount == 0) return format.format(0);

    final formatted = format.format(amount.abs());
    return amount < 0 ? '-$formatted' : '+$formatted';
  }

  /// Get the appropriate color for an amount display using the theme.
  static Color getAmountColor(double amount, ColorScheme colorScheme) {
    if (amount == 0) {
      return colorScheme.onSurface.withOpacity(0.6);
    } else if (amount < 0) {
      return colorScheme.error; // Expenses use the theme's error color.
    } else {
      return colorScheme.tertiary; // Income uses a distinct theme color.
    }
  }

  /// Calculate heatmap opacity based on the absolute amount.
  static double getHeatmapOpacity(double amount) {
    const double maxAmountForOpacity = 200.0; // The amount that gives max opacity.
    const double minOpacity = 0.12;
    const double maxOpacity = 0.8;
    if (amount == 0) return 0.0;

    final ratio = (amount.abs() / maxAmountForOpacity).clamp(0.0, 1.0);
    return minOpacity + (ratio * (maxOpacity - minOpacity));
  }
}
