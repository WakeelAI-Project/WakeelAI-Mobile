class LeaveBalance {
  final String leaveType;
  final int? totalDays;
  final int usedDays;
  final int? balance;
  final int year;

  LeaveBalance({
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.balance,
    required this.year,
  });

  factory LeaveBalance.fromJson(String type, Map<String, dynamic> json) {
    // Convert 'annual' to 'Annual', 'sick' to 'Sick', etc.
    final capitalizedType = type.isEmpty ? '' : '${type[0].toUpperCase()}${type.substring(1)}';
    
    return LeaveBalance(
      leaveType: capitalizedType,
      totalDays: (json['total_days'] as num?)?.toInt(),
      usedDays: (json['used_days'] as num?)?.toInt() ?? 0,
      balance: (json['remaining_days'] as num?)?.toInt(),
      year: DateTime.now().year,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'used_days': usedDays,
      'remaining_days': balance,
    };
  }
}

class EmployeeProfile {
  final String userId;
  final String recordId;
  final String fullName;
  final String email;
  final String jobTitle;
  final String departmentId;
  final String department;
  final String nationalId;
  final int salary;
  final String hireDate;
  final String contractType;
  final String employmentStatus;
  final List<LeaveBalance> leaveBalances;

  EmployeeProfile({
    required this.userId,
    required this.recordId,
    required this.fullName,
    required this.email,
    required this.jobTitle,
    required this.departmentId,
    required this.department,
    required this.nationalId,
    required this.salary,
    required this.hireDate,
    required this.contractType,
    required this.employmentStatus,
    required this.leaveBalances,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      userId: json['user_id'] as String? ?? '',
      recordId: json['record_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      departmentId: json['department_id'] as String? ?? '',
      department: json['department'] as String? ?? '',
      nationalId: json['national_id'] as String? ?? '',
      salary: (json['salary'] as num?)?.toInt() ?? 0,
      hireDate: json['hire_date'] as String? ?? '',
      contractType: json['contract_type'] as String? ?? '',
      employmentStatus: json['employment_status'] as String? ?? '',
      leaveBalances: () {
        final lb = json['leave_balance'] as Map<String, dynamic>?;
        if (lb == null) return <LeaveBalance>[];
        final list = <LeaveBalance>[];
        lb.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            list.add(LeaveBalance.fromJson(key, value));
          }
        });
        return list;
      }(),
    );
  }
}
