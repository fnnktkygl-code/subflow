import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Profile & Health Engine Extended Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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
