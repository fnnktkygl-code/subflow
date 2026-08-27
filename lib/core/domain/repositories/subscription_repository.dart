// lib/core/domain/repositories/subscription_repository.dart

import '../../../models/subscription_model.dart';
import '../../error/failures.dart';
import '../../error/result.dart';

abstract class SubscriptionRepository {
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions();
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription);
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription);
  Future<Result<void, StorageFailure>> deleteSubscription(String id);
  Future<Result<String, StorageFailure>> exportDataAsJson();
  Future<Result<void, StorageFailure>> clearAllData();
}
