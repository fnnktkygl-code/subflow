import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/subscription_model.dart';

/// Utility class for subscription-related calculations and helpers
class SubscriptionUtils {
  /// Calculate the next occurrence date based on cycle
  static DateTime getNextDate(DateTime current, String cycle) {
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

  /// Get upcoming occurrences for a list of subscriptions
  static List<SubscriptionOccurrence> getUpcomingOccurrences(
      List<Subscription> subscriptions, {
        int monthsAhead = 2,
      }) {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month + monthsAhead, 0);
    final occurrences = <SubscriptionOccurrence>[];

    for (final sub in subscriptions) {
      DateTime current = sub.startDate;
      while (current.isBefore(limit)) {
        if (!current.isBefore(now) || DateUtils.isSameDay(current, now)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        DateTime next = getNextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  /// Group occurrences by time period (Today, This Week, This Month, etc.)
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

  /// Get header styling based on section title
  static SubscriptionHeaderStyle getHeaderStyle(
      String title,
      ColorScheme colorScheme,
      ) {
    if (title == 'Due Today') {
      return SubscriptionHeaderStyle(
        color: colorScheme.error,
        icon: Icons.notification_important_rounded,
      );
    } else if (title == 'Due this Week') {
      return SubscriptionHeaderStyle(
        color: Colors.orange.shade700,
        icon: Icons.today_rounded,
      );
    } else if (title == 'Later this Month') {
      return SubscriptionHeaderStyle(
        color: colorScheme.tertiary,
        icon: Icons.calendar_month_rounded,
      );
    } else {
      return SubscriptionHeaderStyle(
        color: colorScheme.primary,
        icon: Icons.event_rounded,
      );
    }
  }
}

/// Data class for subscription occurrence (subscription + date)
class SubscriptionOccurrence {
  final Subscription subscription;
  final DateTime date;

  SubscriptionOccurrence(this.subscription, this.date);
}

/// Data class for header styling
class SubscriptionHeaderStyle {
  final Color color;
  final IconData icon;

  SubscriptionHeaderStyle({
    required this.color,
    required this.icon,
  });
}