import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_date_format.dart';
import '../domain/leave_request.dart';
import '../domain/leave_type.dart';

/// Sniffs [file]'s magic bytes to get a reliable content type for the
/// attachment upload endpoints, which whitelist exactly PDF/JPEG/PNG.
///
/// Filename-extension detection (what `MultipartFile.fromFile` falls back to
/// on its own) is not reliable here: on Android, `file_picker` frequently
/// hands back a path to a cached copy with no extension at all (e.g. content
/// URIs resolved from Google Drive/Downloads, or some camera roll picks), so
/// the request would go out with no usable content type and arrive at the
/// backend as `application/octet-stream`, which its whitelist rejects.
Future<DioMediaType> _attachmentContentType(File file) async {
  final header = Uint8List.fromList(await file.openRead(0, 8).expand((chunk) => chunk).toList());

  if (header.length >= 4 && header[0] == 0x25 && header[1] == 0x50 && header[2] == 0x44 && header[3] == 0x46) {
    return DioMediaType('application', 'pdf'); // %PDF
  }
  if (header.length >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF) {
    return DioMediaType('image', 'jpeg');
  }
  if (header.length >= 8 &&
      header[0] == 0x89 &&
      header[1] == 0x50 &&
      header[2] == 0x4E &&
      header[3] == 0x47 &&
      header[4] == 0x0D &&
      header[5] == 0x0A &&
      header[6] == 0x1A &&
      header[7] == 0x0A) {
    return DioMediaType('image', 'png');
  }

  // Not one of the whitelisted types by content — fall back to whatever the
  // filename suggests (still better than nothing) rather than guessing.
  return MultipartFile.lookupMediaType(file.uri.pathSegments.last) ?? DioMediaType('application', 'octet-stream');
}

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
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
        contentType: await _attachmentContentType(file),
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>('/api/leave-requests/attachments', data: formData);
    final url = response.data?['url'] as String?;
    if (url == null) {
      throw DioException(requestOptions: response.requestOptions, response: response);
    }
    if (url.startsWith('/')) {
      final baseUrl = _dio.options.baseUrl;
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      return '$cleanBaseUrl$url';
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
        contentType: await _attachmentContentType(attachment),
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
