import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import '../models/subscription_model.dart';
import '../../services/notification_service.dart';

class SimplifiedSubscriptionProvider with ChangeNotifier {
  late Box<Subscription> _box;
  final NotificationService _notifications = NotificationService();

  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  double get totalMonthlyCost {
    return _subscriptions.fold(0.0, (sum, sub) {
      if (sub.amount >= 0) return sum;
      return sum + _getMonthlyAmount(sub);
    });
  }

  Map<String, double> get categorySpending {
    final map = <String, double>{};
    for (var sub in _subscriptions) {
      if (sub.amount >= 0) continue;
      final monthly = _getMonthlyAmount(sub);
      map.update(sub.category, (v) => v + monthly, ifAbsent: () => monthly);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  List<Subscription> getActiveSubscriptions(Set<String> snoozedIds) {
    if (snoozedIds.isEmpty) return _subscriptions;
    return _subscriptions.where((sub) => !snoozedIds.contains(sub.id)).toList();
  }

  double getFilteredTotalMonthlyCost(Set<String> snoozedIds) {
    final activeSubs = getActiveSubscriptions(snoozedIds);
    return activeSubs.fold(0.0, (sum, sub) {
      if (sub.amount >= 0) return sum;
      return sum + _getMonthlyAmount(sub);
    });
  }

  Map<String, double> getFilteredCategorySpending(Set<String> snoozedIds) {
    final activeSubs = getActiveSubscriptions(snoozedIds);
    final map = <String, double>{};
    for (var sub in activeSubs) {
      if (sub.amount >= 0) continue;
      final monthly = _getMonthlyAmount(sub);
      map.update(sub.category, (v) => v + monthly, ifAbsent: () => monthly);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  double _getMonthlyAmount(Subscription sub) {
    switch (sub.cycle) {
      case 'Monthly':
        return sub.amount.abs();
      case 'Yearly':
        return sub.amount.abs() / 12;
      case 'Weekly':
        return sub.amount.abs() * 4.348;
      default:
        return sub.amount.abs();
    }
  }

  Future<void> init() async {
    _box = await Hive.openBox<Subscription>('subscriptions_box');
    _subscriptions = _box.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Future<void> addSubscription(Subscription sub) async {
    await _box.put(sub.id, sub);
    _subscriptions = _box.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    _notifications.scheduleNotification(sub);
    notifyListeners();
  }

  Future<void> updateSubscription(Subscription sub) async {
    await _box.put(sub.id, sub);
    _subscriptions = _box.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    _notifications.scheduleNotification(sub);
    notifyListeners();
  }

  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
    _subscriptions = _box.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    _notifications.cancelNotification(id);
    notifyListeners();
  }

  Map<DateTime, List<Subscription>> groupByDate([List<Subscription>? subs]) {
    final subscriptions = subs ?? _subscriptions;
    final map = <DateTime, List<Subscription>>{};
    final projectionLimit = DateTime.now().add(const Duration(days: 365));

    for (var sub in subscriptions) {
      DateTime current = sub.startDate;
      while (current.isBefore(projectionLimit)) {
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        final key = DateTime(current.year, current.month, current.day);
        map.putIfAbsent(key, () => []).add(sub);

        current = _getNextDate(current, sub.cycle);
        if (current == sub.startDate) break;
      }
    }
    return map;
  }

  double calculateCashFlowForMonth(Set<String> snoozedIds, DateTime targetMonth) {
    final activeSubs = getActiveSubscriptions(snoozedIds);
    double total = 0.0;

    for (var sub in activeSubs) {
      DateTime current = sub.startDate;

      // Avance rapide jusqu'à la période concernée
      while (current.year < targetMonth.year ||
          (current.year == targetMonth.year && current.month < targetMonth.month)) {
        DateTime next = _getNextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }

      // Additionne les occurrences dans le mois cible
      while (current.month == targetMonth.month && current.year == targetMonth.year) {
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;
        total += sub.amount;

        DateTime next = _getNextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    return total;
  }

  DateTime _getNextDate(DateTime current, String cycle) {
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
        final isLeapDay = current.month == 2 && current.day == 29;
        return DateTime(current.year + 1, current.month, isLeapDay ? 28 : current.day);
      default:
        return current.add(const Duration(days: 365 * 10));
    }
  }
}

