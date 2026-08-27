import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/money.dart';

void main() {
  group('Money Domain Model', () {
    test('creates Money correctly with default currency', () {
      const m = Money(amount: 49.99);
      expect(m.amount, 49.99);
      expect(m.currencySymbol, '€');
      expect(m.currencyCode, 'EUR');
    });

    test('supports arithmetic operations', () {
      final m1 = Money.fromDouble(20.0);
      final m2 = Money.fromDouble(15.5);

      expect((m1 + m2).amount, closeTo(35.5, 0.001));
      expect((m1 - m2).amount, closeTo(4.5, 0.001));
      expect((m1 * 2).amount, closeTo(40.0, 0.001));
      expect((m1 / 2).amount, closeTo(10.0, 0.001));
    });

    test('formats currency properly', () {
      final m = Money.fromDouble(12.5);
      final str = m.formatted();
      expect(str, contains('12.50'));
      expect(str, contains('€'));
    });

    test('equality works based on value and currency', () {
      final m1 = Money.fromDouble(10.0);
      final m2 = Money.fromDouble(10.0);
      final m3 = Money.fromDouble(10.0, currencySymbol: r'$');

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
    });
  });
}
