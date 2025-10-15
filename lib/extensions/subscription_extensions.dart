import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import 'dart:math';

/// Extension methods for Subscription model
extension SubscriptionExtensions on Subscription {
  /// Get yearly cost from monthly cost
  double get yearlyCost => monthlyCost * 12;

  /// Get cost formatted as currency
  String get formattedCost => '€${monthlyCost.toStringAsFixed(2)}';

  /// Get cost formatted without decimals
  String get formattedCostShort => '€${monthlyCost.toStringAsFixed(0)}';

  /// Get original amount formatted
  String get formattedAmount => '€${amount.toStringAsFixed(2)}';

  /// Display billing cycle nicely
  String get cycleDisplay {
    switch (cycle.toLowerCase()) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Every 3 months';
      case 'annually':
      case 'yearly':
        return 'Yearly';
      case 'weekly':
        return 'Weekly';
      default:
        return cycle;
    }
  }

  /// Get next billing date after today
  DateTime get nextBillingDate {
    final today = DateTime.now();
    DateTime next = startDate;

    while (next.isBefore(today)) {
      next = _getNextDate(next, cycle.toLowerCase());
    }

    return next;
  }

  /// Helper to calculate the next date based on cycle
  DateTime _getNextDate(DateTime current, String cycle) {
    switch (cycle) {
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        int newMonth = current.month + 1;
        int newYear = current.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);
      case 'quarterly':
        int newMonth = current.month + 3;
        int newYear = current.year;
        if (newMonth > 12) {
          newMonth = newMonth % 12;
          newYear += 1;
        }
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);
      case 'annually':
      case 'yearly':
        final isLeapDay = current.month == 2 && current.day == 29;
        return DateTime(current.year + 1, current.month, isLeapDay ? 28 : current.day);
      default:
        return current.add(const Duration(days: 365 * 10));
    }
  }

  /// Check if subscription is active
  bool get isActive {
    final now = DateTime.now();
    return endDate == null || endDate!.isAfter(now);
  }

  /// Days until next billing
  int get daysUntilBilling {
    final today = DateTime.now();
    final billingDay = nextBillingDate;
    return DateTime(billingDay.year, billingDay.month, billingDay.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  /// Check if billing is soon (within reminder days)
  bool get isBillingSoon => daysUntilBilling <= reminderDays && daysUntilBilling >= 0;

  /// Get relative billing date string
  String get relativeBillingDate {
    final days = daysUntilBilling;

    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';

    final date = nextBillingDate;
    return '${date.day}/${date.month}';
  }

  /// Create a copy with modified fields
  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? startDate,
    String? cycle,
    String? logoUrl,
    DateTime? endDate,
    String? category,
    bool? areNotificationsEnabled,
    int? reminderDays,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      cycle: cycle ?? this.cycle,
      logoUrl: logoUrl ?? this.logoUrl,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      areNotificationsEnabled: areNotificationsEnabled ?? this.areNotificationsEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}
