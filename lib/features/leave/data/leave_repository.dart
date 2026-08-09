import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/dio_client.dart';
import '../domain/leave_request_model.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(ref.watch(dioClientProvider));
});

class LeaveRepository {
  final Dio _dio;
  LeaveRepository(this._dio);

  Future<void> submitLeaveRequest(LeaveRequestSubmission submission) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    final formDataMap = <String, dynamic>{
      'LeaveType': submission.leaveType.apiValue,
      'StartDate': dateFormat.format(submission.startDate),
      'EndDate': dateFormat.format(submission.endDate),
    };

    if (submission.reason != null && submission.reason!.isNotEmpty) {
      formDataMap['Reason'] = submission.reason;
    }

    if (submission.attachment != null) {
      formDataMap['attachment'] = await MultipartFile.fromFile(
        submission.attachment!.path,
      );
    }

    final formData = FormData.fromMap(formDataMap);

    await _dio.post('/api/leave-requests', data: formData);
  }
}
