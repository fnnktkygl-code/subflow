import 'package:flutter/material.dart';

/// Model for quick insight statistics
class QuickStat {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor; // ✅ Added background color
  final VoidCallback? onTap;

  const QuickStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor, // ✅ Required field
    this.onTap,
  });
}

/// Model for upcoming payment
class UpcomingPayment {
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final Color color;

  const UpcomingPayment({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.color,
  });

  /// Returns a human-friendly relative date string
  String get relativeDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paymentDay = DateTime(date.year, date.month, date.day);
    final difference = paymentDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    return '${date.day}/${date.month}';
  }

  /// True if the payment is within the next 3 days
  bool get isSoon => DateTime.now().difference(date).inDays.abs() <= 3;
}
