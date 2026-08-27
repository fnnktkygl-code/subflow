// lib/core/data/repositories/shared_prefs_user_profile_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../error/failures.dart';
import '../../error/result.dart';

class SharedPrefsUserProfileRepository implements UserProfileRepository {
  static const String keyHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String keyMonthlyIncome = 'monthlyIncome';
  static const String keySpendingGoal = 'spendingGoal';
  static const String keyThemeIndex = 'themeModeIndex';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Result<bool, StorageFailure>> hasCompletedOnboarding() async {
    try {
      final p = await _prefs;
      return Result.success(p.getBool(keyHasCompletedOnboarding) ?? false);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to read onboarding state', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> setOnboardingCompleted(bool completed) async {
    try {
      final p = await _prefs;
      await p.setBool(keyHasCompletedOnboarding, completed);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to set onboarding state', e));
    }
  }

  @override
  Future<Result<double, StorageFailure>> getMonthlyIncome() async {
    try {
      final p = await _prefs;
      return Result.success(p.getDouble(keyMonthlyIncome) ?? 0.0);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to read monthly income', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> setMonthlyIncome(double income) async {
    try {
      final p = await _prefs;
      await p.setDouble(keyMonthlyIncome, income);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to save monthly income', e));
    }
  }

  @override
  Future<Result<double, StorageFailure>> getSpendingGoal() async {
    try {
      final p = await _prefs;
      return Result.success(p.getDouble(keySpendingGoal) ?? 0.0);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to read spending goal', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> setSpendingGoal(double goal) async {
    try {
      final p = await _prefs;
      await p.setDouble(keySpendingGoal, goal);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to save spending goal', e));
    }
  }

  @override
  Future<Result<int, StorageFailure>> getThemeIndex() async {
    try {
      final p = await _prefs;
      return Result.success(p.getInt(keyThemeIndex) ?? 0);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to read theme index', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> setThemeIndex(int index) async {
    try {
      final p = await _prefs;
      await p.setInt(keyThemeIndex, index);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to save theme index', e));
    }
  }

  @override
  Future<Result<void, StorageFailure>> clearProfile() async {
    try {
      final p = await _prefs;
      await p.remove(keyHasCompletedOnboarding);
      await p.remove(keyMonthlyIncome);
      await p.remove(keySpendingGoal);
      await p.remove(keyThemeIndex);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure('Failed to clear profile', e));
    }
  }
}
