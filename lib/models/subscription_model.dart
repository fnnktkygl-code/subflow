import 'package:hive/hive.dart';

import 'billing_cycle.dart';
import '../utils/logo_utils.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 1)
class Subscription {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final String cycle;

  @HiveField(5)
  final String logoUrl;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final bool areNotificationsEnabled;

  @HiveField(9)
  final int reminderDays;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.cycle,
    required this.logoUrl,
    this.endDate,
    this.category = 'General',
    this.areNotificationsEnabled = true,
    this.reminderDays = 2,
  });

  /// Canonical BillingCycle enum representation
  BillingCycle get cycleEnum => BillingCycle.fromString(cycle);

  /// Canonical monthly cost calculation using unified domain rules
  double get monthlyCost => cycleEnum.toMonthly(amount);

  /// Canonical annual cost calculation
  double get annualCost => cycleEnum.toAnnual(amount);

  /// Dynamically resolved logo URL, sanitizing legacy broken URLs and empty fields
  String get effectiveLogoUrl {
    if (logoUrl.isNotEmpty && !logoUrl.contains('demo.dev')) {
      return logoUrl;
    }
    return fetchLogo(name);
  }

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