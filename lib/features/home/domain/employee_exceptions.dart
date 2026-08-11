enum EmployeeFailureReason {
  unauthorized,
  serverError,
  unknown,
}

class EmployeeFailure implements Exception {
  const EmployeeFailure(this.reason, [this.message]);
  final EmployeeFailureReason reason;
  final String? message;

  @override
  String toString() => 'EmployeeFailure: $reason${message != null ? ' ($message)' : ''}';
}
