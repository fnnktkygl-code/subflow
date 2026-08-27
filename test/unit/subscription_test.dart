import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/models/billing_cycle.dart';

void main() {
  group('Subscription Model Unit Tests', () {
    test('monthlyCost computes accurate monthly equivalent', () {
      final monthlySub = Subscription(
        id: 'sub-1',
        name: 'Netflix',
        amount: 15.99,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        logoUrl: '',
      );
      expect(monthlySub.monthlyCost, closeTo(15.99, 0.001));
      expect(monthlySub.cycleEnum, BillingCycle.monthly);

      final yearlySub = Subscription(
        id: 'sub-2',
        name: 'Amazon Prime',
        amount: 69.90,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Yearly',
        logoUrl: '',
      );
      expect(yearlySub.monthlyCost, closeTo(69.90 / 12.0, 0.001));
      expect(yearlySub.cycleEnum, BillingCycle.yearly);
    });

    test('annualCost computes accurate annual cost', () {
      final sub = Subscription(
        id: 'sub-3',
        name: 'Spotify',
        amount: 10.99,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        logoUrl: '',
      );
      expect(sub.annualCost, closeTo(10.99 * 12.0, 0.001));
    });
  });
}
