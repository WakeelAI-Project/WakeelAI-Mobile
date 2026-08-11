enum LeaveStatus {
  draft('Draft'),
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String value;
  const LeaveStatus(this.value);

  static LeaveStatus fromString(String val) {
    return LeaveStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => LeaveStatus.draft,
    );
  }
}

class LeaveRequest {
  final String id;
  final String leaveType;
  final String startDate;
  final String endDate;
  final LeaveStatus status;
  final int daysRequested;
  final String? reason;
  final String? hrNote;
  final String? attachmentName;

  LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.daysRequested,
    this.reason,
    this.hrNote,
    this.attachmentName,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['request_id'] ?? json['id'] ?? '',
      leaveType: json['leave_type'] ?? 'Annual',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: LeaveStatus.fromString(json['status'] ?? 'Draft'),
      daysRequested: json['days_requested'] ?? 0,
      reason: json['reason'],
      hrNote: json['hr_note'],
      attachmentName: json['attachment_name'] ?? json['attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': id,
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'status': status.value,
      'days_requested': daysRequested,
      'reason': reason,
      'hr_note': hrNote,
      'attachment_name': attachmentName,
    };
  }

  LeaveRequest copyWith({
    String? id,
    String? leaveType,
    String? startDate,
    String? endDate,
    LeaveStatus? status,
    int? daysRequested,
    String? reason,
    String? hrNote,
    String? attachmentName,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      daysRequested: daysRequested ?? this.daysRequested,
      reason: reason ?? this.reason,
      hrNote: hrNote ?? this.hrNote,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}
