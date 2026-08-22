import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_date_format.dart';
import '../domain/leave_request.dart';
import '../domain/leave_type.dart';

class LeaveRequestsPage {
  const LeaveRequestsPage({required this.items, required this.page, required this.hasMore});

  final List<LeaveRequest> items;
  final int page;
  final bool hasMore;
}

/// `{request_id, status, days_requested}` — the response body of
/// `POST /api/leave-requests`. Deliberately not a full [LeaveRequest]: the
/// backend doesn't return one on creation.
class CreateLeaveDraftResult {
  const CreateLeaveDraftResult({required this.requestId, required this.status, required this.daysRequested});

  final String requestId;
  final String status;
  final int daysRequested;

  factory CreateLeaveDraftResult.fromJson(Map<String, dynamic> json) {
    return CreateLeaveDraftResult(
      requestId: json['request_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      daysRequested: json['days_requested'] as int? ?? 0,
    );
  }
}

abstract class LeaveApiClient {
  Future<LeaveRequestsPage> getLeaveRequests({String? status, int page = 1, int limit = 20});
  Future<LeaveRequest> getLeaveRequest(String id);
  Future<void> submitDraft(String id);
  Future<void> cancelDraft(String id);

  /// `POST /api/leave-requests/attachments` (multipart). Returns the
  /// uploaded file's `url` — the field the backend's own draft-creation
  /// endpoints (direct and AI-driven) actually accept, not `attachment_id`.
  Future<String> uploadAttachment(File file);

  /// `POST /api/leave-requests` (multipart). The attachment, when present,
  /// is uploaded inline on this same request — the backend's direct-entry
  /// endpoint (`LeaveRequestService.CreateDraftAsync`) only ever reads the
  /// inline file stream, never a pre-uploaded `attachment_url` (that field
  /// only applies to the AI-driven creation path).
  Future<CreateLeaveDraftResult> createLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  });
}

class DioLeaveApiClient implements LeaveApiClient {
  DioLeaveApiClient(this._dio);
  final Dio _dio;

  @override
  Future<LeaveRequestsPage> getLeaveRequests({String? status, int page = 1, int limit = 20}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status;
      }
      final response = await _dio.get<Map<String, dynamic>>('/api/leave-requests', queryParameters: queryParams);
      final data = response.data ?? const {};
      final items = (data['data'] as List<dynamic>? ?? const [])
          .map((json) => LeaveRequest.fromJson(json as Map<String, dynamic>))
          .toList();
      final total = data['total'] as int? ?? items.length;
      return LeaveRequestsPage(items: items, page: page, hasMore: page * limit < total);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequest> getLeaveRequest(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/leave-requests/$id');
      return LeaveRequest.fromJson(response.data ?? const {});
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

  @override
  Future<String> uploadAttachment(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    final response = await _dio.post<Map<String, dynamic>>('/api/leave-requests/attachments', data: formData);
    final url = response.data?['url'] as String?;
    if (url == null) {
      throw DioException(requestOptions: response.requestOptions, response: response);
    }
    return url;
  }

  @override
  Future<CreateLeaveDraftResult> createLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    // Field names are the C# property names of CreateLeaveRequestDto
    // (PascalCase) — ASP.NET's [FromForm] binder matches multipart field
    // names against property names directly, ignoring the [JsonPropertyName]
    // snake_case attributes used for this same DTO's JSON body elsewhere.
    final formDataMap = <String, dynamic>{
      'LeaveType': leaveType.apiValue,
      'StartDate': AppDateFormat.toApi(startDate),
      'EndDate': AppDateFormat.toApi(endDate),
    };
    if (reason != null && reason.isNotEmpty) {
      formDataMap['Reason'] = reason;
    }
    if (attachment != null) {
      formDataMap['attachment'] = await MultipartFile.fromFile(
        attachment.path,
        filename: attachment.uri.pathSegments.last,
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/leave-requests',
      data: FormData.fromMap(formDataMap),
    );
    return CreateLeaveDraftResult.fromJson(response.data ?? const {});
  }
}

final leaveApiClientProvider = Provider<LeaveApiClient>((ref) {
  return DioLeaveApiClient(ref.watch(dioClientProvider));
});
