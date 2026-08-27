import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  final List<Subscription> _data = [];

  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async {
    return Result.success(List.from(_data));
  }

  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async {
    _data.add(subscription);
    return const Result.success(null);
  }

  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async {
    final idx = _data.indexWhere((s) => s.id == subscription.id);
    if (idx != -1) _data[idx] = subscription;
    return const Result.success(null);
  }

  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async {
    _data.removeWhere((s) => s.id == id);
    return const Result.success(null);
  }

  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async {
    return const Result.success('{"subscriptions":[]}');
  }

  @override
  Future<Result<void, StorageFailure>> clearAllData() async {
    _data.clear();
    return const Result.success(null);
  }
}

void main() {
  group('SimplifiedSubscriptionProvider with Injected Repository', () {
    late FakeSubscriptionRepository fakeRepo;
    late SimplifiedSubscriptionProvider provider;

    setUp(() {
      fakeRepo = FakeSubscriptionRepository();
      provider = SimplifiedSubscriptionProvider(repository: fakeRepo);
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

    test('correctly calculates cash flow for a target month', () async {
      await provider.init();

      final sub1 = Subscription(
        id: 's1',
        name: 'Rent',
        amount: -800.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Housing',
        logoUrl: '',
      );

      await provider.addSubscription(sub1);

      final cashflowMarch2026 = provider.calculateCashFlowForMonth({}, DateTime(2026, 3, 1));
      expect(cashflowMarch2026, closeTo(-800.0, 0.001));
    });
  });
}
