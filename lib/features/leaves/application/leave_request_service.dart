import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leave_api_client.dart';
import '../domain/leave_request_exceptions.dart';
import '../domain/leave_type.dart';
import '../domain/leave_request.dart';

/// Façade over [LeaveApiClient] for the AI Chat feature's `leave_draft`
/// result card: submit/cancel a draft — regardless of whether it was
/// created via the direct-entry form or by the AI itself — and pre-upload a
/// Sick-leave medical report before handing its `url` to the AI via
/// `field_values`.
///
/// Submit/cancel deliberately call the plain employee-facing
/// `/api/leave-requests/{id}/...` endpoints (already used by
/// [LeaveApiClient]/My Leave Requests), not `/api/ai/leave-requests/...` as
/// the requirements doc suggested — the `/api/ai/` prefix is gated by an
/// internal M2M API key (see Wakeel.API's InternalApiKeyMiddleware) that
/// only the Node AI service holds, so the mobile app can't call it and was
/// never meant to: the AI creates drafts server-side via that internal
/// route, but the employee still submits/cancels them through the same
/// public endpoints the direct-entry screen uses.
class LeaveRequestService {
  LeaveRequestService(this._client);
  final LeaveApiClient _client;

  /// Checks if a request is still a draft. Returns false if submitted, cancelled, or deleted.
  Future<bool> isLeaveDraft(String requestId) async {
    try {
      final request = await _client.getLeaveRequest(requestId);
      return request.status == LeaveStatus.draft;
    } on DioException catch (e) {
      final reason = _draftReasonFor(e);
      if (reason == LeaveDraftFailureReason.notFound) {
        return false;
      }
      rethrow;
    }
  }

  /// `PATCH /api/leave-requests/{requestId}/submit`. Throws
  /// [LeaveDraftException] on failure (404 not-found or 409 not-a-draft).
  Future<void> submitLeaveDraft(String requestId) async {
    try {
      await _client.submitDraft(requestId);
    } on DioException catch (e) {
      throw LeaveDraftException(_draftReasonFor(e));
    }
  }

  /// `DELETE /api/leave-requests/{requestId}`. Throws [LeaveDraftException]
  /// on failure (404 not-found or 409 not-a-draft).
  Future<void> deleteLeaveDraft(String requestId) async {
    try {
      await _client.cancelDraft(requestId);
    } on DioException catch (e) {
      throw LeaveDraftException(_draftReasonFor(e));
    }
  }

  /// `POST /api/leave-requests/attachments`. Returns the uploaded file's
  /// `url` for the chat composer to include in `field_values`. The
  /// response also carries an `attachment_id`, but Story E5 is explicit
  /// that only the url is ever sent onward to the AI, so it's discarded
  /// here. Throws [LeaveAttachmentUploadException] on failure.
  Future<String> uploadLeaveAttachment(File file) async {
    try {
      return await _client.uploadAttachment(file);
    } on DioException catch (e) {
      throw LeaveAttachmentUploadException(_attachmentReasonFor(e));
    }
  }

  /// `POST /api/leave-requests` (multipart, attachment inline). Throws
  /// [LeaveDraftCreationException] on failure (400 validation, 422
  /// insufficient balance, or 422 attachment-required).
  Future<CreateLeaveDraftResult> createLeaveDraft({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    try {
      return await _client.createLeaveRequest(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        attachment: attachment,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final errorCode = body is Map ? body['error'] as String? : null;
      final message = body is Map ? body['message'] as String? : null;
      throw LeaveDraftCreationException(_creationReasonFor(errorCode), message: message);
    }
  }

  LeaveDraftCreationFailureReason _creationReasonFor(String? errorCode) {
    switch (errorCode) {
      case 'validation_error':
        return LeaveDraftCreationFailureReason.validationError;
      case 'insufficient_leave_balance':
        return LeaveDraftCreationFailureReason.insufficientBalance;
      case 'attachment_required':
        return LeaveDraftCreationFailureReason.attachmentRequired;
      case 'overlapping_leave_request':
        return LeaveDraftCreationFailureReason.overlappingRequest;
      default:
        return LeaveDraftCreationFailureReason.unknown;
    }
  }

  LeaveDraftFailureReason _draftReasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'leave_request_not_found':
        return LeaveDraftFailureReason.notFound;
      case 'not_a_draft':
        return LeaveDraftFailureReason.notADraft;
      default:
        return LeaveDraftFailureReason.unknown;
    }
  }

  LeaveAttachmentFailureReason _attachmentReasonFor(DioException e) {
    final body = e.response?.data;
    final errorCode = body is Map ? body['error'] as String? : null;
    switch (errorCode) {
      case 'validation_error':
        return LeaveAttachmentFailureReason.missingFile;
      case 'invalid_attachment':
        return LeaveAttachmentFailureReason.invalidAttachment;
      default:
        return LeaveAttachmentFailureReason.unknown;
    }
  }
}

final leaveRequestServiceProvider = Provider<LeaveRequestService>((ref) {
  return LeaveRequestService(ref.watch(leaveApiClientProvider));
});
