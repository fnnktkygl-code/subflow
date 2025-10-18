// lib/utils/subscription_utils.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/subscription_model.dart';
import '../theme/theme.dart'; // Import your theme file to access the new colors

/// Utility class for subscription-related calculations and helpers
class SubscriptionUtils {
  // ... (getNextDate remains the same) ...
  /// Calculate the next occurrence date based on cycle
  static DateTime getNextDate(DateTime current, String cycle) {
    switch (cycle.toLowerCase()) { // ✅ Use toLowerCase for safety
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        var newMonth = current.month + 1;
        var newYear = current.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);
      case 'yearly':
      case 'annually': // ✅ Handle 'annually'
      // ✅ Use correct leap year logic here too for forward calculation
        final isFeb29 = current.month == 2 && current.day == 29;
        // If it's Feb 29, next year's date should be Feb 28 unless next year is also a leap year
        final nextYearIsLeap = ((current.year + 1) % 4 == 0) && (((current.year + 1) % 100 != 0) || ((current.year + 1) % 400 == 0));
        int day = current.day;
        if(isFeb29 && !nextYearIsLeap) {
          day = 28;
        } else {
          // Ensure day exists in next year's month
          final daysInMonthNextYear = DateUtils.getDaysInMonth(current.year + 1, current.month);
          day = min(current.day, daysInMonthNextYear);
        }

        return DateTime(
          current.year + 1,
          current.month,
          day,
        );
      default:
      // A far-future date for unknown cycles
        return DateTime.now().add(const Duration(days: 365 * 10));
    }
  }


  // ✅ Helper function for leap year check
  static bool _isLeapYear(int year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  // ✅ CORRECTED: Calculate the previous occurrence date based on cycle
  static DateTime _getPreviousDate(DateTime current, String cycle) {
    switch (cycle.toLowerCase()) { // ✅ Use toLowerCase for safety
      case 'weekly':
        return current.subtract(const Duration(days: 7));
      case 'monthly':
        var newMonth = current.month - 1;
        var newYear = current.year;
        if (newMonth < 1) {
          newMonth = 12;
          newYear--;
        }
        final daysInPrevMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInPrevMonth);
        return DateTime(newYear, newMonth, day);
      case 'yearly':
      case 'annually': // ✅ Handle 'annually'
        final currentIsFeb29 = current.month == 2 && current.day == 29;
        // Check if the *previous* year was a leap year
        bool prevYearWasLeap = _isLeapYear(current.year - 1); // ✅ Use helper

        int day = current.day;
        if (currentIsFeb29) {
          // This case should ideally not happen if date logic is correct elsewhere,
          // but going back from Feb 29 means the previous was Feb 28/29
          day = prevYearWasLeap ? 29 : 28;
        }
        // Special case: going back from Mar 1st immediately after a leap year's Feb 29
        else if (current.month == 3 && current.day == 1 && prevYearWasLeap) {
          return DateTime(current.year - 1, 2, 29);
        }
        else {
          // Ensure day exists in previous year's month (e.g., going back from Mar 31)
          final daysInMonthPrevYear = DateUtils.getDaysInMonth(current.year - 1, current.month);
          day = min(current.day, daysInMonthPrevYear);
        }
        return DateTime(current.year - 1, current.month, day);

      default:
      // A far-past date for unknown cycles
        return DateTime.now().subtract(const Duration(days: 365 * 10));
    }
  }

  // ... (getRelevantOccurrences remains the same) ...
  /// ✅ MODIFIED: Get upcoming occurrences AND recent past occurrences
  /// for a list of subscriptions
  static List<SubscriptionOccurrence> getRelevantOccurrences(
      List<Subscription> subscriptions, {
        int monthsAhead = 2,
      }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);
    final limitFuture = DateTime(now.year, now.month + monthsAhead, 0); // End of N months ahead
    final occurrences = <SubscriptionOccurrence>[];
    final foundPastIds = <String>{}; // Track which subs already have a past occurrence added

    for (final sub in subscriptions) {
      DateTime current = sub.startDate;
      DateTime lastValidPast = sub.startDate; // Keep track of the latest date before 'today'

      // --- Find the most recent occurrence BEFORE today ---
      // Go backward first to find the anchor point if start date is far in future or past
      DateTime anchor = sub.startDate;
      if (anchor.isAfter(today)){
        while(anchor.isAfter(today)) {
          DateTime prev = _getPreviousDate(anchor, sub.cycle);
          if (prev.isAfter(anchor) || prev == anchor) break; // Safety break
          anchor = prev;
        }
        lastValidPast = anchor; // The first date before or on today
      } else {
        // Start date is before or on today, find the *next* one to start iterating forward
        // This handles cases where start date is way in the past
        while (anchor.isBefore(today)) {
          DateTime next = getNextDate(anchor, sub.cycle);
          if (next.isBefore(anchor) || next == anchor) break; // Safety
          if (!next.isBefore(today)) { // Found the first date >= today
            lastValidPast = anchor; // The one right before it
            break;
          }
          anchor = next;
        }
        // If loop finished and anchor is still before today, it means the very last calculated date IS the lastValidPast
        if(anchor.isBefore(today)) lastValidPast = anchor;
      }


      // --- Iterate forward from the anchor date ---
      current = getNextDate(lastValidPast, sub.cycle); // Start from the date *after* lastValidPast

      // --- Add the lastValidPast if relevant ---
      if (!lastValidPast.isBefore(startOfCurrentMonth) && lastValidPast.isBefore(today)) {
        if (foundPastIds.add(sub.id)) {
          occurrences.add(SubscriptionOccurrence(sub, lastValidPast));
        }
      }


      // --- Iterate forward for upcoming dates ---
      while (current.isBefore(limitFuture)) {

        // Only add upcoming/today's dates
        if (!current.isBefore(today)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }

        // --- Check End Date ---
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        // --- Advance to next date ---
        DateTime next = getNextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break; // Safety break
        current = next;
      }
    }

    // Sort all relevant occurrences (past and future)
    occurrences.sort((a, b) {
      int dateComp = a.date.compareTo(b.date);
      if (dateComp != 0) return dateComp;
      // Optional: secondary sort by name if dates are same
      return a.subscription.name.compareTo(b.subscription.name);
    });
    return occurrences;
  }


  // ... (groupOccurrences remains the same) ...
  /// ✅ MODIFIED: Group occurrences including the new "Paid Earlier" section
  static Map<String, List<SubscriptionOccurrence>> groupOccurrences(
      List<SubscriptionOccurrence> occurrences,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday)); // Sunday this week
    final map = <String, List<SubscriptionOccurrence>>{};

    for (var occ in occurrences) {
      String key;
      // Check for past payments first
      if (occ.date.isBefore(today)) {
        // Ensure it's within the current month
        if (occ.date.year == today.year && occ.date.month == today.month) {
          key = 'Paid Earlier This Month';
        } else {
          continue; // Skip past payments from previous months
        }
      }
      // Check upcoming payments
      else if (DateUtils.isSameDay(occ.date, today)) {
        key = 'Due Today';
      } else if (!occ.date.isAfter(endOfWeek)) {
        key = 'Due this Week';
      } else if (occ.date.month == today.month) {
        key = 'Later this Month';
      } else {
        key = DateFormat('MMMM yyyy').format(occ.date); // Future months
      }
      map.putIfAbsent(key, () => []).add(occ);
    }
    return map;
  }

  // ... (getHeaderStyle remains the same) ...
  /// Get header styling based on section title
  static SubscriptionHeaderStyle getHeaderStyle(
      String title,
      ColorScheme colorScheme,
      ) {
    // ✅ ADDED: Style for the new section
    if (title == 'Paid Earlier This Month') {
      return SubscriptionHeaderStyle(
        color: colorScheme.tertiary.withOpacity(0.8), // Use tertiary but slightly muted
        icon: Icons.history_rounded, // History icon
      );
    }
    if (title == 'Due Today') {
      return SubscriptionHeaderStyle(
        color: colorScheme.error, // Stays the same, as it's semantic
        icon: Icons.notification_important_rounded,
      );
    } else if (title == 'Due this Week') {
      return const SubscriptionHeaderStyle(
        color: warningAmber, // Using the modern, consistent amber color
        icon: Icons.calendar_view_week_rounded, // Changed icon
      );
    } else if (title == 'Later this Month') {
      return SubscriptionHeaderStyle(
        color: colorScheme.primary.withOpacity(0.8), // Use primary but slightly muted
        icon: Icons.calendar_month_rounded,
      );
    } else { // Future months
      return SubscriptionHeaderStyle(
        color: colorScheme.secondary.withOpacity(0.8), // Use secondary but slightly muted
        icon: Icons.event_rounded,
      );
    }
  }
} // End of SubscriptionUtils class

// ... (SubscriptionOccurrence and SubscriptionHeaderStyle remain the same) ...
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

  const SubscriptionHeaderStyle({
    required this.color,
    required this.icon,
  });
}