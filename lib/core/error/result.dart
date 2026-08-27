// lib/core/error/result.dart

import 'failures.dart';

sealed class Result<T, E extends Failure> {
  const Result();

  const factory Result.success(T data) = Success<T, E>;
  const factory Result.failure(E failure) = Error<T, E>;

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Error<T, E>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Error() => null,
      };

  E? get failureOrNull => switch (this) {
        Success() => null,
        Error(:final failure) => failure,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(E failure) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Error(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T, E extends Failure> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

final class Error<T, E extends Failure> extends Result<T, E> {
  final E failure;
  const Error(this.failure);
}
