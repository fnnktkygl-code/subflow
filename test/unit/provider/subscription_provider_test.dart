import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';

class FailingSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async {
    return const Result.failure(StorageFailure('Simulated database corruption error'));
  }

  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async {
    return const Result.failure(StorageFailure('Disk full error'));
  }

  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async {
    return const Result.failure(StorageFailure('Write permission denied'));
  }

  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async {
    return const Result.failure(StorageFailure('Row not found'));
  }

  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async {
    return const Result.failure(StorageFailure('Export failure'));
  }

  @override
  Future<Result<void, StorageFailure>> clearAllData() async {
    return const Result.failure(StorageFailure('Wipe failure'));
  }
}

class InMemorySubscriptionRepository implements SubscriptionRepository {
  final Map<String, Subscription> _storage = {};

  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async {
    return Result.success(_storage.values.toList());
  }

  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async {
    _storage[subscription.id] = subscription;
    return const Result.success(null);
  }

  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async {
    _storage[subscription.id] = subscription;
    return const Result.success(null);
  }

  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async {
    _storage.remove(id);
    return const Result.success(null);
  }

  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async {
    return Result.success('{"count": ${_storage.length}}');
  }

  @override
  Future<Result<void, StorageFailure>> clearAllData() async {
    _storage.clear();
    return const Result.success(null);
  }
}

void main() {
  group('SimplifiedSubscriptionProvider Unified Test Suite', () {
    late InMemorySubscriptionRepository repo;
    late SimplifiedSubscriptionProvider provider;

    setUp(() {
      repo = InMemorySubscriptionRepository();
      provider = SimplifiedSubscriptionProvider(repository: repo);
    });

    test('starts with empty list before init', () {
      expect(provider.subscriptions, isEmpty);
      expect(provider.totalMonthlyCost, 0.0);
    });

    test('adds subscriptions and computes monthly totals properly', () async {
      await provider.init();

      final sub1 = Subscription(
        id: 's1',
        name: 'Netflix',
        amount: -15.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Entertainment',
        logoUrl: '',
      );

      final sub2 = Subscription(
        id: 's2',
        name: 'Gym',
        amount: -30.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Health',
        logoUrl: '',
      );

      await provider.addSubscription(sub1);
      await provider.addSubscription(sub2);

      expect(provider.subscriptions.length, 2);
      expect(provider.totalMonthlyCost, closeTo(45.0, 0.001));
      expect(provider.categorySpending['Entertainment'], closeTo(15.0, 0.001));
      expect(provider.categorySpending['Health'], closeTo(30.0, 0.001));
    });

    test('replaces existing subscription on update', () async {
      await provider.init();

      final originalSub = Subscription(
        id: 'sub-edit-1',
        name: 'Phone Plan',
        amount: -20.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Utilities',
        logoUrl: '',
      );

      await provider.addSubscription(originalSub);
      expect(provider.totalMonthlyCost, closeTo(20.0, 0.001));

      final upgradedSub = originalSub.copyWith(
        amount: -25.0,
        name: 'Phone Plan 5G Unlimited',
      );

      await provider.updateSubscription(upgradedSub);
      expect(provider.subscriptions.length, equals(1));
      expect(provider.subscriptions.first.name, equals('Phone Plan 5G Unlimited'));
      expect(provider.totalMonthlyCost, closeTo(25.0, 0.001));
    });

    test('deletes subscription and updates spending', () async {
      await provider.init();

      final sub1 = Subscription(
        id: 's1',
        name: 'Spotify',
        amount: -10.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Music',
        logoUrl: '',
      );

      await provider.addSubscription(sub1);
      expect(provider.subscriptions.length, 1);

      await provider.deleteSubscription('s1');
      expect(provider.subscriptions, isEmpty);
      expect(provider.totalMonthlyCost, 0.0);
    });

    test('What-If simulation calculations accurately exclude snoozed items', () async {
      await provider.init();

      final sub1 = Subscription(
        id: 's1',
        name: 'Netflix',
        amount: -15.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Entertainment',
        logoUrl: '',
      );

      final sub2 = Subscription(
        id: 's2',
        name: 'Gym',
        amount: -30.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Health',
        logoUrl: '',
      );

      await provider.addSubscription(sub1);
      await provider.addSubscription(sub2);

      // Total is 45€. If Netflix (-15€) is snoozed, cashflow expense is -30€
      final adjustedFlow = provider.calculateCashFlowForMonth({'s1'}, DateTime(2026, 3, 1));
      expect(adjustedFlow, closeTo(-30.0, 0.001));
    });

    test('handles storage failures gracefully without crashing', () async {
      final failingRepo = FailingSubscriptionRepository();
      final failingProvider = SimplifiedSubscriptionProvider(repository: failingRepo);

      await failingProvider.init();
      expect(failingProvider.subscriptions, isEmpty);

      final testSub = Subscription(
        id: 'test-fail-1',
        name: 'Test',
        amount: -5.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Other',
        logoUrl: '',
      );

      await failingProvider.addSubscription(testSub);
      expect(failingProvider.subscriptions, isEmpty);
    });
  });
}
