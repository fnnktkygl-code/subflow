// lib/core/domain/repositories/user_profile_repository.dart

import '../../error/failures.dart';
import '../../error/result.dart';

abstract class UserProfileRepository {
  Future<Result<bool, StorageFailure>> hasCompletedOnboarding();
  Future<Result<void, StorageFailure>> setOnboardingCompleted(bool completed);
  Future<Result<double, StorageFailure>> getMonthlyIncome();
  Future<Result<void, StorageFailure>> setMonthlyIncome(double income);
  Future<Result<double, StorageFailure>> getSpendingGoal();
  Future<Result<void, StorageFailure>> setSpendingGoal(double goal);
  Future<Result<int, StorageFailure>> getThemeIndex();
  Future<Result<void, StorageFailure>> setThemeIndex(int index);
  Future<Result<void, StorageFailure>> clearProfile();
}
