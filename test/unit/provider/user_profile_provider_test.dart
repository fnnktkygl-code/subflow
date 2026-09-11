import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfileProvider Unified Test Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('calculates subscription percentage and health status accurately', () {
      final provider = UserProfileProvider();

      // When no income is set, percentage is null and health status is unknown
      expect(provider.getSubscriptionPercentage(50.0), isNull);
      expect(provider.getHealthStatus(50.0), IncomeHealthStatus.unknown);

      // Set income to 2000€
      provider.setMonthlyIncome(2000.0);

      // 100€ on 2000€ = 5% (< 10% -> Healthy)
      expect(provider.getSubscriptionPercentage(100.0), closeTo(5.0, 0.01));
      expect(provider.getHealthStatus(100.0), IncomeHealthStatus.healthy);

      // 250€ on 2000€ = 12.5% (10%-15% -> Warning)
      expect(provider.getSubscriptionPercentage(250.0), closeTo(12.5, 0.01));
      expect(provider.getHealthStatus(250.0), IncomeHealthStatus.warning);

      // 400€ on 2000€ = 20% (> 15% -> Danger)
      expect(provider.getSubscriptionPercentage(400.0), closeTo(20.0, 0.01));
      expect(provider.getHealthStatus(400.0), IncomeHealthStatus.danger);
    });

    test('handles zero income and boundary thresholds without division by zero', () {
      final provider = UserProfileProvider();

      // Zero income
      provider.setMonthlyIncome(0.0);
      expect(provider.getSubscriptionPercentage(50.0), isNull);
      expect(provider.getHealthStatus(50.0), equals(IncomeHealthStatus.unknown));

      // Normal income, zero spending
      provider.setMonthlyIncome(2500.0);
      expect(provider.getSubscriptionPercentage(0.0), equals(0.0));
      expect(provider.getHealthStatus(0.0), equals(IncomeHealthStatus.healthy));
    });

    test('generates helpful insight messages', () {
      final provider = UserProfileProvider();
      provider.setMonthlyIncome(1000.0);

      final healthyInsight = provider.getIncomeInsight(50.0);
      expect(healthyInsight, contains('excellent'));

      final warningInsight = provider.getIncomeInsight(120.0);
      expect(warningInsight, contains('sweet spot'));

      final dangerInsight = provider.getIncomeInsight(250.0);
      expect(dangerInsight, contains('over the recommended'));
    });

    test('manages and persists onboarding completion state', () async {
      final provider = UserProfileProvider();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(provider.hasCompletedOnboarding, isFalse);

      await provider.completeOnboarding();
      expect(provider.hasCompletedOnboarding, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_completed_onboarding'), isTrue);
    });

    test('manages custom spending goals and resets correctly', () async {
      final provider = UserProfileProvider();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(provider.spendingGoal, isNull);

      await provider.updateSpendingGoal(250.0);
      expect(provider.spendingGoal, equals(250.0));

      await provider.resetIncomeAndGoal();
      expect(provider.monthlyIncome, isNull);
      expect(provider.spendingGoal, isNull);
    });
  });
}
