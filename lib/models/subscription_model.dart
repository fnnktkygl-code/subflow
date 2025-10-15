import 'package:hive/hive.dart';

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

  // ✅ FIX: The new getter to calculate the monthly cost.
  double get monthlyCost {
    switch (cycle.toLowerCase()) {
      case 'monthly':
        return amount;
      case 'quarterly':
        return amount / 3.0;
      case 'annually':
        return amount / 12.0;
      case 'weekly':
        return amount * 4.0; // Approximation
      default:
        return amount;
    }
  }
}