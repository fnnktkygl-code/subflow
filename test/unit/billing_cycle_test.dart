import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/billing_cycle.dart';

void main() {
  group('BillingCycle Parsing', () {
    test('parses standard strings correctly', () {
      expect(BillingCycle.fromString('Weekly'), BillingCycle.weekly);
      expect(BillingCycle.fromString('weekly'), BillingCycle.weekly);
      expect(BillingCycle.fromString('Monthly'), BillingCycle.monthly);
      expect(BillingCycle.fromString('monthly'), BillingCycle.monthly);
      expect(BillingCycle.fromString('Quarterly'), BillingCycle.quarterly);
      expect(BillingCycle.fromString('quarterly'), BillingCycle.quarterly);
      expect(BillingCycle.fromString('Yearly'), BillingCycle.yearly);
      expect(BillingCycle.fromString('yearly'), BillingCycle.yearly);
      expect(BillingCycle.fromString('Annually'), BillingCycle.yearly);
      expect(BillingCycle.fromString('annual'), BillingCycle.yearly);
    });

    test('parses french aliases correctly', () {
      expect(BillingCycle.fromString('mensuel'), BillingCycle.monthly);
      expect(BillingCycle.fromString('hebdomadaire'), BillingCycle.weekly);
      expect(BillingCycle.fromString('trimestriel'), BillingCycle.quarterly);
      expect(BillingCycle.fromString('annuel'), BillingCycle.yearly);
    });

    test('defaults to monthly on unknown or null inputs', () {
      expect(BillingCycle.fromString(null), BillingCycle.monthly);
      expect(BillingCycle.fromString('unknown_cycle'), BillingCycle.monthly);
      expect(BillingCycle.fromString(''), BillingCycle.monthly);
    });
  });

  group('BillingCycle Financial Calculations', () {
    test('monthly conversion works accurately across all cycles', () {
      // Monthly 10€ -> 10€/mo
      expect(BillingCycle.monthly.toMonthly(10.0), closeTo(10.0, 0.001));

      // Yearly 120€ -> 10€/mo
      expect(BillingCycle.yearly.toMonthly(120.0), closeTo(10.0, 0.001));

      // Quarterly 30€ -> 10€/mo
      expect(BillingCycle.quarterly.toMonthly(30.0), closeTo(10.0, 0.001));

      // Weekly 10€ -> (10 * 52 / 12) = 43.333€/mo
      expect(BillingCycle.weekly.toMonthly(10.0), closeTo(43.3333, 0.001));
    });

    test('annual conversion works accurately across all cycles', () {
      expect(BillingCycle.monthly.toAnnual(10.0), closeTo(120.0, 0.001));
      expect(BillingCycle.yearly.toAnnual(120.0), closeTo(120.0, 0.001));
      expect(BillingCycle.quarterly.toAnnual(30.0), closeTo(120.0, 0.001));
      expect(BillingCycle.weekly.toAnnual(10.0), closeTo(520.0, 0.001));
    });
  });

  group('BillingCycle Date Arithmetic', () {
    test('weekly adds 7 days', () {
      final start = DateTime(2026, 1, 1);
      expect(BillingCycle.weekly.nextDate(start), DateTime(2026, 1, 8));
    });

    test('monthly handles month rollover and short months correctly', () {
      final startJan31 = DateTime(2026, 1, 31);
      // Feb 2026 has 28 days
      expect(BillingCycle.monthly.nextDate(startJan31), DateTime(2026, 2, 28));

      final startMarch31 = DateTime(2026, 3, 31);
      // April has 30 days
      expect(BillingCycle.monthly.nextDate(startMarch31), DateTime(2026, 4, 30));
    });

    test('yearly handles year rollover', () {
      final start = DateTime(2026, 8, 26);
      expect(BillingCycle.yearly.nextDate(start), DateTime(2027, 8, 26));
    });
  });
}
