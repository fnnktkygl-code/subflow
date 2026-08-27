// lib/provider/simplified_subscription_provider.dart

import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../models/billing_cycle.dart';
import '../services/notification_service.dart';
import '../core/domain/repositories/subscription_repository.dart';
import '../core/data/repositories/hive_subscription_repository.dart';

class SimplifiedSubscriptionProvider with ChangeNotifier {
  final SubscriptionRepository _repository;
  final NotificationService _notifications;

  List<Subscription> _subscriptions = [];

  SimplifiedSubscriptionProvider({
    SubscriptionRepository? repository,
    NotificationService? notifications,
  })  : _repository = repository ?? HiveSubscriptionRepository(),
        _notifications = notifications ?? NotificationService();

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  double get totalMonthlyCost {
    return _subscriptions.fold(0.0, (sum, sub) {
      if (sub.amount >= 0) return sum;
      return sum + getMonthlyAmount(sub);
    });
  }

  Map<String, double> get categorySpending {
    final map = <String, double>{};
    for (var sub in _subscriptions) {
      if (sub.amount >= 0) continue;
      final monthly = getMonthlyAmount(sub);
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
      return sum + getMonthlyAmount(sub);
    });
  }

  Map<String, double> getFilteredCategorySpending(Set<String> snoozedIds) {
    final activeSubs = getActiveSubscriptions(snoozedIds);
    final map = <String, double>{};
    for (var sub in activeSubs) {
      if (sub.amount >= 0) continue;
      final monthly = getMonthlyAmount(sub);
      map.update(sub.category, (v) => v + monthly, ifAbsent: () => monthly);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  double getMonthlyAmount(Subscription sub) {
    return sub.monthlyCost;
  }

  Future<void> init() async {
    final result = await _repository.getSubscriptions();
    result.fold(
      onSuccess: (subs) {
        _subscriptions = subs;
        notifyListeners();
      },
      onFailure: (failure) {
        debugPrint('Failed to load subscriptions: $failure');
      },
    );
  }

  Future<void> addSubscription(Subscription sub) async {
    final result = await _repository.saveSubscription(sub);
    result.fold(
      onSuccess: (_) {
        _subscriptions = [..._subscriptions, sub]
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        _notifications.scheduleNotification(sub);
        notifyListeners();
      },
      onFailure: (failure) {
        debugPrint('Failed to add subscription: $failure');
      },
    );
  }

  Future<void> updateSubscription(Subscription sub) async {
    final result = await _repository.updateSubscription(sub);
    result.fold(
      onSuccess: (_) {
        _subscriptions = _subscriptions.map((s) => s.id == sub.id ? sub : s).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        _notifications.scheduleNotification(sub);
        notifyListeners();
      },
      onFailure: (failure) {
        debugPrint('Failed to update subscription: $failure');
      },
    );
  }

  Future<void> deleteSubscription(String id) async {
    final result = await _repository.deleteSubscription(id);
    result.fold(
      onSuccess: (_) {
        _subscriptions = _subscriptions.where((s) => s.id != id).toList();
        _notifications.cancelNotification(id);
        notifyListeners();
      },
      onFailure: (failure) {
        debugPrint('Failed to delete subscription: $failure');
      },
    );
  }

  Future<void> clearAllSubscriptions() async {
    for (var sub in _subscriptions) {
      _notifications.cancelNotification(sub.id);
    }
    await _repository.clearAllData();
    _subscriptions = [];
    notifyListeners();
  }

  Future<String?> exportData() async {
    final result = await _repository.exportDataAsJson();
    return result.dataOrNull;
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

        final next = BillingCycle.fromString(sub.cycle).nextDate(current);
        if (next == current || next.isBefore(current)) break;
        current = next;
      }
    }
    return map;
  }

  double calculateCashFlowForMonth(
      Set<String> snoozedIds, DateTime targetMonth) {
    final activeSubs = getActiveSubscriptions(snoozedIds);
    double total = 0.0;

    for (var sub in activeSubs) {
      final cycle = BillingCycle.fromString(sub.cycle);
      DateTime current = sub.startDate;

      // Fast-forward to the relevant period
      while (current.year < targetMonth.year ||
          (current.year == targetMonth.year && current.month < targetMonth.month)) {
        DateTime next = cycle.nextDate(current);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }

      // Sum occurrences within the target month
      while (current.month == targetMonth.month &&
          current.year == targetMonth.year) {
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;
        total += sub.amount;

        DateTime next = cycle.nextDate(current);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    return total;
  }
}