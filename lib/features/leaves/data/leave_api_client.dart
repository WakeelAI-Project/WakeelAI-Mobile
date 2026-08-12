import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/leave_request.dart';

abstract class LeaveApiClient {
  Future<List<LeaveRequest>> getLeaveRequests({String? status, int page = 1, int limit = 20});
  Future<void> submitDraft(String id);
  Future<void> cancelDraft(String id);
}

class DioLeaveApiClient implements LeaveApiClient {
  DioLeaveApiClient(this._dio);
  final Dio _dio;

  @override
  Future<List<LeaveRequest>> getLeaveRequests({String? status, int page = 1, int limit = 20}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status;
      }
      final response = await _dio.get('/api/leave-requests', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitDraft(String id) async {
    try {
      await _dio.patch('/api/leave-requests/$id/submit');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelDraft(String id) async {
    try {
      await _dio.delete('/api/leave-requests/$id');
    } catch (e) {
      rethrow;
    }
  }
}

final leaveApiClientProvider = Provider<LeaveApiClient>((ref) {
  return DioLeaveApiClient(ref.watch(dioClientProvider));
});
