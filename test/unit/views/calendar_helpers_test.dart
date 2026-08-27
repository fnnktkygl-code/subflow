import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/views/calendar_helpers.dart';
import 'package:subflow_app/models/subscription_model.dart';

void main() {
  group('Calendar Helpers & Projections Tests', () {
    test('SubscriptionOccurrence equality and hashCode operate on ID and Date', () {
      final sub = Subscription(
        id: 'sub-1',
        name: 'iCloud',
        amount: -2.99,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Tech',
        logoUrl: '',
      );

      final occ1 = SubscriptionOccurrence(sub, DateTime(2026, 3, 1));
      final occ2 = SubscriptionOccurrence(sub, DateTime(2026, 3, 1));
      final occ3 = SubscriptionOccurrence(sub, DateTime(2026, 4, 1));

      expect(occ1, equals(occ2));
      expect(occ1.hashCode, equals(occ2.hashCode));
      expect(occ1, isNot(equals(occ3)));
      expect(occ1.toString(), contains('iCloud'));
    });

    test('getHeatmapOpacity scales proportionally and clamps at limits', () {
      // 0€ spend has 0 opacity
      expect(CalendarHelpers.getHeatmapOpacity(0.0), equals(0.0));

      // Small spend has minimum opacity threshold (~0.12)
      expect(CalendarHelpers.getHeatmapOpacity(1.0), greaterThanOrEqualTo(0.12));

      // 100€ spend is midway (~0.46)
      final midOpacity = CalendarHelpers.getHeatmapOpacity(100.0);
      expect(midOpacity, greaterThan(0.3));
      expect(midOpacity, lessThan(0.6));

      // 200€ and above clamps at maxOpacity (0.8)
      expect(CalendarHelpers.getHeatmapOpacity(200.0), closeTo(0.8, 0.001));
      expect(CalendarHelpers.getHeatmapOpacity(500.0), equals(0.8));
    });

    test('getUpcomingOccurrences returns chronologically sorted future dates', () {
      final now = DateTime.now();
      final subMonthly = Subscription(
        id: 'sub-m',
        name: 'Gym',
        amount: -30.0,
        startDate: DateTime(now.year, now.month, 1),
        cycle: 'Monthly',
        category: 'Health',
        logoUrl: '',
      );

      final subWeekly = Subscription(
        id: 'sub-w',
        name: 'Meal Kit',
        amount: -50.0,
        startDate: now,
        cycle: 'Weekly',
        category: 'Food',
        logoUrl: '',
      );

      final occurrences = CalendarHelpers.getUpcomingOccurrences([subMonthly, subWeekly]);

      expect(occurrences, isNotEmpty);
      for (int i = 0; i < occurrences.length - 1; i++) {
        expect(occurrences[i].date.isAfter(occurrences[i + 1].date), isFalse);
      }
    });

    test('getUpcomingOccurrences respects subscription endDate and stops generating', () {
      final now = DateTime.now();
      final expiredSub = Subscription(
        id: 'sub-exp',
        name: 'Trial Service',
        amount: -10.0,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 10)),
        cycle: 'Monthly',
        category: 'Entertainment',
        logoUrl: '',
      );

      final occurrences = CalendarHelpers.getUpcomingOccurrences([expiredSub]);
      expect(occurrences, isEmpty);
    });

    test('getNext7DaysTotal and getNext7DaysCount calculate upcoming 7 days spend accurately', () {
      final now = DateTime.now();
      final subDueIn2Days = Subscription(
        id: 'sub-2d',
        name: 'Netflix',
        amount: -15.0,
        startDate: now.add(const Duration(days: 2)),
        cycle: 'Monthly',
        category: 'Entertainment',
        logoUrl: '',
      );

      final subDueIn20Days = Subscription(
        id: 'sub-20d',
        name: 'Gym',
        amount: -45.0,
        startDate: now.add(const Duration(days: 20)),
        cycle: 'Monthly',
        category: 'Health',
        logoUrl: '',
      );

      final total = CalendarHelpers.getNext7DaysTotal([subDueIn2Days, subDueIn20Days]);
      final count = CalendarHelpers.getNext7DaysCount([subDueIn2Days, subDueIn20Days]);

      expect(total, equals(15.0));
      expect(count, equals(1));
    });
  });
}
