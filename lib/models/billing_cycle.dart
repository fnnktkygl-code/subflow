// lib/models/billing_cycle.dart

enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  yearly;

  static BillingCycle fromString(String? raw) {
    if (raw == null) return BillingCycle.monthly;
    switch (raw.trim().toLowerCase()) {
      case 'weekly':
      case 'week':
      case 'hebdomadaire':
        return BillingCycle.weekly;
      case 'quarterly':
      case 'quarter':
      case 'trimestriel':
        return BillingCycle.quarterly;
      case 'yearly':
      case 'year':
      case 'annually':
      case 'annual':
      case 'annuel':
        return BillingCycle.yearly;
      case 'monthly':
      case 'month':
      case 'mensuel':
      default:
        return BillingCycle.monthly;
    }
  }

  String get displayName {
    switch (this) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  /// Exact monthly conversion factor (52/12 weeks per month)
  double get monthlyMultiplier {
    switch (this) {
      case BillingCycle.weekly:
        return 52.0 / 12.0; // ~4.333333333333333
      case BillingCycle.monthly:
        return 1.0;
      case BillingCycle.quarterly:
        return 1.0 / 3.0;
      case BillingCycle.yearly:
        return 1.0 / 12.0;
    }
  }

  /// Converts an amount in this cycle to the equivalent monthly cost
  double toMonthly(double amount) => amount.abs() * monthlyMultiplier;

  /// Converts an amount in this cycle to the equivalent annual cost
  double toAnnual(double amount) => toMonthly(amount) * 12.0;

  /// Calculates the next occurrence date accurately
  DateTime nextDate(DateTime from, [int count = 1]) {
    switch (this) {
      case BillingCycle.weekly:
        return from.add(Duration(days: 7 * count));
      case BillingCycle.monthly:
        return _addMonths(from, count);
      case BillingCycle.quarterly:
        return _addMonths(from, 3 * count);
      case BillingCycle.yearly:
        return _addMonths(from, 12 * count);
    }
  }

  static DateTime _addMonths(DateTime date, int monthsToAdd) {
    final newYear = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
    final newMonth = ((date.month - 1 + monthsToAdd) % 12) + 1;
    final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;
    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
