import '../models/subscription_model.dart';

/// Extension methods for Subscription model
extension SubscriptionExtensions on Subscription {
  /// Get yearly cost from monthly cost
  double get yearlyCost => annualCost;

  /// Get cost formatted as currency
  String get formattedCost => '€${monthlyCost.toStringAsFixed(2)}';

  /// Get cost formatted without decimals
  String get formattedCostShort => '€${monthlyCost.toStringAsFixed(0)}';

  /// Get original amount formatted
  String get formattedAmount => '€${amount.abs().toStringAsFixed(2)}';

  /// Display billing cycle nicely
  String get cycleDisplay => cycleEnum.displayName;

  /// Get next billing date after today
  DateTime get nextBillingDate {
    final today = DateTime.now();
    DateTime next = startDate;

    while (next.isBefore(today)) {
      next = cycleEnum.nextDate(next);
    }

    return next;
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
