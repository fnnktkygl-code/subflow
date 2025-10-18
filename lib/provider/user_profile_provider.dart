// lib/provider/user_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider extends ChangeNotifier {
  double? _monthlyIncome;
  DateTime? _incomeLastUpdated;
  bool _hasOptedInForIncomeTracking = false;
  bool _hasDismissedIncomePrompt = false;
  DateTime _firstUseDate = DateTime.now();
  double _spendingGoal = 250.0; // ✅ ADD: Add default spending goal

  // Getters
  double? get monthlyIncome => _monthlyIncome;
  DateTime? get incomeLastUpdated => _incomeLastUpdated;
  bool get hasOptedInForIncomeTracking => _hasOptedInForIncomeTracking;
  bool get hasDismissedIncomePrompt => _hasDismissedIncomePrompt;
  double get spendingGoal => _spendingGoal; // ✅ ADD: Getter for the goal

  int get daysUsed {
    return DateTime.now().difference(_firstUseDate).inDays;
  }

  UserProfileProvider() {
    _loadProfile();
  }

  // Calculate percentage of income spent
  double? getSubscriptionPercentage(double totalMonthlyCost) {
    if (_monthlyIncome == null || _monthlyIncome! <= 0) return null;
    return (totalMonthlyCost / _monthlyIncome!) * 100;
  }

  // Get health status
  IncomeHealthStatus getHealthStatus(double totalMonthlyCost) {
    final percentage = getSubscriptionPercentage(totalMonthlyCost);
    if (percentage == null) return IncomeHealthStatus.unknown;

    if (percentage < 10) return IncomeHealthStatus.healthy;
    if (percentage < 15) return IncomeHealthStatus.warning;
    return IncomeHealthStatus.danger;
  }

  // Should show income prompt?
  bool shouldShowIncomePrompt(int subscriptionCount) {
    if (_hasOptedInForIncomeTracking || _hasDismissedIncomePrompt) {
      return false;
    }
    return subscriptionCount >= 3 && daysUsed >= 2;
  }

  // Set monthly income
  Future<void> setMonthlyIncome(double income) async {
    _monthlyIncome = income;
    _incomeLastUpdated = DateTime.now();
    _hasOptedInForIncomeTracking = true;
    await _saveProfile();
    notifyListeners();
  }

  // Dismiss income prompt
  Future<void> dismissIncomePrompt() async {
    _hasDismissedIncomePrompt = true;
    await _saveProfile();
    notifyListeners();
  }

  // Update income
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

  // ✅ ADD: Method to update the spending goal
  Future<void> updateSpendingGoal(double newGoal) async {
    _spendingGoal = newGoal;
    await _saveProfile();
    notifyListeners();
  }

  // Generate income insight
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

  // Generate category insight
  String? getCategoryInsight(String category, double categoryAmount) {
    if (_monthlyIncome == null || _monthlyIncome! <= 0) return null;

    final percentage = (categoryAmount / _monthlyIncome!) * 100;

    if (percentage > 5) {
      return "$category is ${percentage.toStringAsFixed(1)}% of your income (€${categoryAmount.toStringAsFixed(0)}/month). That's quite high for a single category.";
    }

    return null;
  }

  // Persistence
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (_monthlyIncome != null) {
      await prefs.setDouble('monthly_income', _monthlyIncome!);
    } else {
      await prefs.remove('monthly_income');
    }

    if (_incomeLastUpdated != null) {
      await prefs.setInt('income_last_updated', _incomeLastUpdated!.millisecondsSinceEpoch);
    }

    await prefs.setBool('has_opted_in_income', _hasOptedInForIncomeTracking);
    await prefs.setBool('has_dismissed_income_prompt', _hasDismissedIncomePrompt);
    await prefs.setInt('first_use_date', _firstUseDate.millisecondsSinceEpoch);
    await prefs.setDouble('spending_goal', _spendingGoal); // ✅ ADD: Save goal
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
      // First time user
      _firstUseDate = DateTime.now();
      await prefs.setInt('first_use_date', _firstUseDate.millisecondsSinceEpoch);
    }

    _spendingGoal = prefs.getDouble('spending_goal') ?? 250.0; // ✅ ADD: Load goal

    notifyListeners();
  }
}

enum IncomeHealthStatus { healthy, warning, danger, unknown }