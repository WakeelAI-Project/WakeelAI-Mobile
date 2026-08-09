import 'dart:io';

enum LeaveType {
  annual('Annual'),
  sick('Sick'),
  unpaid('Unpaid');

  final String apiValue;
  const LeaveType(this.apiValue);
}

class LeaveRequestSubmission {
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final File? attachment;

  LeaveRequestSubmission({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.attachment,
  });

  bool get isSick => leaveType == LeaveType.sick;
}
