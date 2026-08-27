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
  group('Subscription Provider Extended & Counter-Tests', () {
    test('What-If simulation calculations accurately exclude snoozed items', () async {
      final repo = InMemorySubscriptionRepository();
      final provider = SimplifiedSubscriptionProvider(repository: repo);
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

      final sub3 = Subscription(
        id: 's3',
        name: 'Cloud Storage',
        amount: -10.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Tech',
        logoUrl: '',
      );

      await provider.addSubscription(sub1);
      await provider.addSubscription(sub2);
      await provider.addSubscription(sub3);

      expect(provider.totalMonthlyCost, closeTo(55.0, 0.001));

      // Calculate cash flow when Netflix (15€) is snoozed
      final snoozedIds = {'s1'};
      final adjustedFlow = provider.calculateCashFlowForMonth(snoozedIds, DateTime(2026, 3, 1));

      // 55€ - 15€ = 40€ expense (-40€)
      expect(adjustedFlow, closeTo(-40.0, 0.001));
    });

    test('replaces existing subscription on update', () async {
      final repo = InMemorySubscriptionRepository();
      final provider = SimplifiedSubscriptionProvider(repository: repo);
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

    test('handles storage failures gracefully without crashing', () async {
      final failingRepo = FailingSubscriptionRepository();
      final provider = SimplifiedSubscriptionProvider(repository: failingRepo);

      // Provider init handles failure by initializing an empty state safely
      await provider.init();
      expect(provider.subscriptions, isEmpty);

      final testSub = Subscription(
        id: 'test-fail-1',
        name: 'Test',
        amount: -5.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Other',
        logoUrl: '',
      );

      // Attempting to add with failing storage does not throw an unhandled exception
      await provider.addSubscription(testSub);
      expect(provider.subscriptions, isEmpty);
    });
  });
}
