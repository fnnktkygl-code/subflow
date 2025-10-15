import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/subscription_model.dart'; // Defines the 'Subscription' class
import '../provider/simplified_subscription_provider.dart'; // The Provider class
import '../widgets/subscription_card.dart'; // The custom card widget

// ======================================================================
// Subscription List View
// ======================================================================

class SubscriptionListView extends StatelessWidget {
  const SubscriptionListView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Access the data provider
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    // 2. Calculate and sort upcoming subscription dates
    final occurrences = _getUpcomingOccurrences(provider.subscriptions);

    // 3. Group those dates into logical sections
    final grouped = _groupOccurrences(occurrences);

    // 4. Handle the case where there are no upcoming subscriptions
    if (occurrences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "No upcoming subscriptions!",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 5. Build the list using the grouped data
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: grouped.entries.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final groupTitle = entry.key;
        final groupItems = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header (e.g., "DUE TODAY")
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Text(
                groupTitle.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
            // List of Subscription Cards for this section
            ...groupItems.map((occ) => SubscriptionCard(
              subscription: occ.subscription,
              displayDate: occ.date,
              isAmountBlurred: false,
            )),
          ],
        );
      },
    );
  }

  /// Calculates all upcoming payment dates for the next two months.
  List<SubscriptionOccurrence> _getUpcomingOccurrences(List<Subscription> subs) {
    // Current date is October 11, 2025
    final now = DateTime.now();
    // Look ahead to the end of November 2025
    final limit = DateTime(now.year, now.month + 2, 0);
    final occurrences = <SubscriptionOccurrence>[];

    for (final sub in subs) {
      DateTime current = sub.startDate;
      while (current.isBefore(limit)) {
        // Add the date if it's today or in the future
        if (!current.isBefore(now) || DateUtils.isSameDay(current, now)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }
        // Stop if the subscription has a defined end date that has passed
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        // Calculate the next payment date
        DateTime next = _nextDate(current, sub.cycle);
        // Safety break to prevent infinite loops from bad data
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    // Sort the final list by date
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  /// Groups a list of occurrences into a map with section titles as keys.
  Map<String, List<SubscriptionOccurrence>> _groupOccurrences(List<SubscriptionOccurrence> occurrences) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Determine the upcoming Sunday, which marks the end of the current week
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
        // For future months, use the month name and year as the key
        key = DateFormat('MMMM yyyy').format(occ.date);
      }
      // Add the occurrence to the correct list in the map
      map.putIfAbsent(key, () => []).add(occ);
    }
    return map;
  }

  /// Calculates the next payment date based on the subscription cycle.
  DateTime _nextDate(DateTime current, String cycle) {
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
        // Handle cases like advancing from Jan 31st, where Feb doesn't have 31 days.
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);
      case 'Yearly':
      // Handle leap years correctly for a Feb 29th subscription
        final isLeapDay = current.month == 2 && current.day == 29;
        return DateTime(current.year + 1, current.month, isLeapDay ? 28 : current.day);
      default:
      // A failsafe to prevent infinite loops if the cycle is invalid.
        return DateTime.now().add(const Duration(days: 365 * 10));
    }
  }
}

/// A helper class to link a Subscription object with a specific upcoming payment date.
class SubscriptionOccurrence {
  final Subscription subscription;
  final DateTime date;
  SubscriptionOccurrence(this.subscription, this.date);
}
