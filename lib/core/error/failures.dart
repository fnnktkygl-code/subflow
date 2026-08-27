// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, [super.cause, this.statusCode]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.cause]);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.cause]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.cause]);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.cause]);
}
