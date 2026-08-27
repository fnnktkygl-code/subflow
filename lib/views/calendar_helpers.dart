import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../models/billing_cycle.dart';
import '../theme/custom_colors.dart';

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
    return BillingCycle.fromString(cycle).nextDate(current);
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
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        // Include if it's today or in the future
        if (!current.isBefore(now) || DateUtils.isSameDay(current, now)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }

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

  /// Get appropriate color for amount display using theme extension
  static Color getAmountColor(double amount, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>();

    if (amount == 0) {
      return colorScheme.onSurface.withValues(alpha: 0.4);
    } else if (amount < 0) {
      // Use the theme-aware color, with a fallback to the error color
      return customColors?.heatmapExpense ?? colorScheme.error;
    } else {
      // Use the theme-aware color, with a fallback to the tertiary color
      return customColors?.heatmapIncome ?? colorScheme.tertiary;
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

  /// Calculate upcoming 7-day total spend from active subscriptions
  static double getNext7DaysTotal(List<Subscription> subs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next7Days = today.add(const Duration(days: 7));
    final occurrences = getUpcomingOccurrences(subs);

    double total = 0.0;
    for (final occ in occurrences) {
      final occDate = DateTime(occ.date.year, occ.date.month, occ.date.day);
      if (!occDate.isBefore(today) && !occDate.isAfter(next7Days)) {
        if (occ.subscription.amount < 0) {
          total += occ.subscription.amount.abs();
        }
      }
    }
    return total;
  }

  /// Count number of renewals in next 7 days
  static int getNext7DaysCount(List<Subscription> subs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next7Days = today.add(const Duration(days: 7));
    final occurrences = getUpcomingOccurrences(subs);

    int count = 0;
    for (final occ in occurrences) {
      final occDate = DateTime(occ.date.year, occ.date.month, occ.date.day);
      if (!occDate.isBefore(today) && !occDate.isAfter(next7Days)) {
        if (occ.subscription.amount < 0) {
          count++;
        }
      }
    }
    return count;
  }
}
