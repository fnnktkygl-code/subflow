// lib/provider/user_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider extends ChangeNotifier {
  double? _monthlyIncome;
  DateTime? _incomeLastUpdated;
  bool _hasOptedInForIncomeTracking = false;
  bool _hasDismissedIncomePrompt = false;
  DateTime _firstUseDate = DateTime.now();
  // ✅ GOAL: Now nullable, with no default value.
  double? _spendingGoal;
  bool _hasCompletedOnboarding = false;

  // Getters
  double? get monthlyIncome => _monthlyIncome;
  DateTime? get incomeLastUpdated => _incomeLastUpdated;
  bool get hasOptedInForIncomeTracking => _hasOptedInForIncomeTracking;
  bool get hasDismissedIncomePrompt => _hasDismissedIncomePrompt;
  // ✅ GETTER: Updated to return a nullable double.
  double? get spendingGoal => _spendingGoal;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;


  int get daysUsed {
    return DateTime.now().difference(_firstUseDate).inDays;
  }

  UserProfileProvider() {
    _loadProfile();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> resetIncomeAndGoal() async {
    _monthlyIncome = null;
    _incomeLastUpdated = null;
    _hasOptedInForIncomeTracking = false;
    // ✅ RESET: Sets goal back to null.
    _spendingGoal = null;
    await _saveProfile();
    notifyListeners();
  }


  double? getSubscriptionPercentage(double totalMonthlyCost) {
    if (_monthlyIncome == null || _monthlyIncome! <= 0) return null;
    return (totalMonthlyCost / _monthlyIncome!) * 100;
  }

  IncomeHealthStatus getHealthStatus(double totalMonthlyCost) {
    final percentage = getSubscriptionPercentage(totalMonthlyCost);
    if (percentage == null) return IncomeHealthStatus.unknown;

    if (percentage < 10) return IncomeHealthStatus.healthy;
    if (percentage < 15) return IncomeHealthStatus.warning;
    return IncomeHealthStatus.danger;
  }

  bool shouldShowIncomePrompt(int subscriptionCount) {
    if (_hasOptedInForIncomeTracking || _hasDismissedIncomePrompt) {
      return false;
    }
    return subscriptionCount >= 3 && daysUsed >= 2;
  }

  Future<void> setMonthlyIncome(double income) async {
    _monthlyIncome = income;
    _incomeLastUpdated = DateTime.now();
    _hasOptedInForIncomeTracking = true;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> dismissIncomePrompt() async {
    _hasDismissedIncomePrompt = true;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> updateIncome(double? newIncome) async {
    if (newIncome == null) {
      _monthlyIncome = null;
      _hasOptedInForIncomeTracking = false;
    } else {
      _monthlyIncome = newIncome;
      _incomeLastUpdated = DateTime.now();
      _hasOptedInForIncomeTracking = true;
    }
    await _saveProfile();
    notifyListeners();
  }

  // ✅ UPDATE: The new goal can be null to remove it.
  Future<void> updateSpendingGoal(double? newGoal) async {
    _spendingGoal = newGoal;
    await _saveProfile();
    notifyListeners();
  }

  String? getIncomeInsight(double totalMonthlyCost) {
    if (_monthlyIncome == null || _monthlyIncome! <= 0) return null;

    final percentage = (totalMonthlyCost / _monthlyIncome!) * 100;

    if (percentage < 10) {
      return "You're only spending ${percentage.toStringAsFixed(1)}% of your income on subscriptions. That's excellent! 🌟";
    }

    if (percentage < 15) {
      final recommended = _monthlyIncome! * 0.10;
      final difference = totalMonthlyCost - recommended;
      return "Subscriptions take ${percentage.toStringAsFixed(1)}% of your income. Consider cutting €${difference.toStringAsFixed(0)}/month to hit the 10% sweet spot.";
    }

    final recommended = _monthlyIncome! * 0.10;
    final tooCostly = totalMonthlyCost - recommended;
    return "⚠️ Subscriptions are ${percentage.toStringAsFixed(1)}% of your income. You're €${tooCostly.toStringAsFixed(0)}/month over the recommended 10% limit.";
  }

  String? getCategoryInsight(String category, double categoryAmount) {
    if (_monthlyIncome == null || _monthlyIncome! <= 0) return null;

    final percentage = (categoryAmount / _monthlyIncome!) * 100;

    if (percentage > 5) {
      return "$category is ${percentage.toStringAsFixed(1)}% of your income (€${categoryAmount.toStringAsFixed(0)}/month). That's quite high for a single category.";
    }

    return null;
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (_monthlyIncome != null) {
      await prefs.setDouble('monthly_income', _monthlyIncome!);
    } else {
      await prefs.remove('monthly_income');
    }

    if (_incomeLastUpdated != null) {
      await prefs.setInt('income_last_updated', _incomeLastUpdated!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('income_last_updated');
    }

    await prefs.setBool('has_opted_in_income', _hasOptedInForIncomeTracking);
    await prefs.setBool('has_dismissed_income_prompt', _hasDismissedIncomePrompt);
    await prefs.setInt('first_use_date', _firstUseDate.millisecondsSinceEpoch);

    // ✅ SAVE: Handle saving a null or double value.
    if (_spendingGoal != null) {
      await prefs.setDouble('spending_goal', _spendingGoal!);
    } else {
      await prefs.remove('spending_goal');
    }
    await prefs.setBool('has_completed_onboarding', _hasCompletedOnboarding);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyIncome = prefs.getDouble('monthly_income');

    final lastUpdatedMs = prefs.getInt('income_last_updated');
    if (lastUpdatedMs != null) {
      _incomeLastUpdated = DateTime.fromMillisecondsSinceEpoch(lastUpdatedMs);
    }

    _hasOptedInForIncomeTracking = prefs.getBool('has_opted_in_income') ?? false;
    _hasDismissedIncomePrompt = prefs.getBool('has_dismissed_income_prompt') ?? false;

    final firstUseMs = prefs.getInt('first_use_date');
    if (firstUseMs != null) {
      _firstUseDate = DateTime.fromMillisecondsSinceEpoch(firstUseMs);
    } else {
      _firstUseDate = DateTime.now();
      await prefs.setInt('first_use_date', _firstUseDate.millisecondsSinceEpoch);
    }

    // ✅ LOAD: Load a nullable double, defaulting to null if not found.
    _spendingGoal = prefs.getDouble('spending_goal');

    _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

    notifyListeners();
  }
}

enum IncomeHealthStatus { healthy, warning, danger, unknown }

