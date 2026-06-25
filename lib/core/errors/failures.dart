/// Mino Chat — error hierarchy.
/// Every recoverable error in the app should be a [MinoFailure] subclass.

sealed class MinoFailure implements Exception {
  final String message;
  final String? code;
  final dynamic cause;
  const MinoFailure(this.message, {this.code, this.cause});

  @override
  String toString() => 'MinoFailure($code): $message';
}

class NetworkFailure extends MinoFailure {
  const NetworkFailure(super.message, {super.code, super.cause});
}

class AuthFailure extends MinoFailure {
  const AuthFailure(super.message, {super.code, super.cause});
}

class StorageFailure extends MinoFailure {
  const StorageFailure(super.message, {super.code, super.cause});
}

class PermissionFailure extends MinoFailure {
  const PermissionFailure(super.message, {super.code, super.cause});
}

class BleFailure extends MinoFailure {
  const BleFailure(super.message, {super.code, super.cause});
}

class RealtimeFailure extends MinoFailure {
  const RealtimeFailure(super.message, {super.code, super.cause});
}

class NotFoundFailure extends MinoFailure {
  const NotFoundFailure(super.message, {super.code, super.cause});
}

class ValidationFailure extends MinoFailure {
  const ValidationFailure(super.message, {super.code, super.cause});
}

class UnknownFailure extends MinoFailure {
  const UnknownFailure(super.message, {super.code, super.cause});
}

/// Convert any thrown object into a [MinoFailure].
MinoFailure toFailure(Object e, StackTrace st) {
  if (e is MinoFailure) return e;
  if (e is FormatException) return ValidationFailure(e.message, code: 'format');
  if (e is StateError) return UnknownFailure(e.message, code: 'state');
  return UnknownFailure(e.toString(), cause: e);
}
