// lib/core/data/repositories/hive_subscription_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subscription_model.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../error/failures.dart';
import '../../error/result.dart';

class HiveSubscriptionRepository implements SubscriptionRepository {
  static const String boxName = 'subscriptions_box';
  Box<Subscription>? _box;

  Future<Box<Subscription>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    try {
      _box = await Hive.openBox<Subscription>(boxName);
      return _box!;
    } catch (e) {
      debugPrint('Hive openBox error: $e');
      throw StorageFailure('Could not open Hive box: $boxName', e);
    }
  }

  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async {
    try {
      final box = await _getBox();
      final list = box.values.toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      return Result.success(list);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to fetch subscriptions', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async {
    try {
      final box = await _getBox();
      await box.put(subscription.id, subscription);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to save subscription', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async {
    return saveSubscription(subscription);
  }

  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to delete subscription', e));
    }
  }

  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async {
    try {
      final box = await _getBox();
      final items = box.values.map((s) => {
        'id': s.id,
        'name': s.name,
        'amount': s.amount,
        'startDate': s.startDate.toIso8601String(),
        'cycle': s.cycle,
        'category': s.category,
        'logoUrl': s.logoUrl,
        'reminderDays': s.reminderDays,
        'areNotificationsEnabled': s.areNotificationsEnabled,
      }).toList();
      return Result.success(jsonEncode({'exportedAt': DateTime.now().toIso8601String(), 'subscriptions': items}));
    } catch (e) {
      return Result.failure(StorageFailure('Failed to export data', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> clearAllData() async {
    try {
      final box = await _getBox();
      await box.clear();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to clear all data', e));
    }
  }
}
