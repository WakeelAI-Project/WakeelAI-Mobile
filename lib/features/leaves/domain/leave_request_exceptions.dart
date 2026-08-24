/// Error codes from `PATCH /api/leave-requests/{id}/submit` and
/// `DELETE /api/leave-requests/{id}` (Wakeel.API's LeaveRequestsController).
enum LeaveDraftFailureReason {
  /// 404 `{"error": "leave_request_not_found"}` — doesn't exist, or belongs
  /// to another employee/company.
  notFound,

  /// 409 `{"error": "not_a_draft"}` — already submitted or cancelled.
  notADraft,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when submitting or cancelling a leave draft is rejected.
class LeaveDraftException implements Exception {
  const LeaveDraftException(this.reason);
  final LeaveDraftFailureReason reason;
}

/// Error codes from `POST /api/leave-requests/attachments`.
enum LeaveAttachmentFailureReason {
  /// 400 `{"error": "validation_error"}` — no file provided.
  missingFile,

  /// 400 `{"error": "invalid_attachment"}` — wrong type, or over the 10MB limit.
  invalidAttachment,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when a leave-attachment upload is rejected.
class LeaveAttachmentUploadException implements Exception {
  const LeaveAttachmentUploadException(this.reason);
  final LeaveAttachmentFailureReason reason;
}

/// Error codes from `POST /api/leave-requests` (creating a new draft).
enum LeaveDraftCreationFailureReason {
  /// 400 `{"error": "validation_error"}` — invalid/missing dates or leave_type.
  validationError,

  /// 422 `{"error": "insufficient_leave_balance"}`.
  insufficientBalance,

  /// 422 `{"error": "attachment_required"}` — Sick leave with no file. The
  /// client blocks this case before ever submitting, but the server can
  /// still return it (e.g. a stale client), so it must be handled too.
  attachmentRequired,

  /// 409 `{"error": "overlapping_leave_request"}` — dates overlap an
  /// existing Pending or Approved request. [LeaveDraftCreationException.message]
  /// carries the server's own description of which one, since only the
  /// server knows the conflicting request's type, dates, and status.
  overlappingRequest,

  /// Any other error (network failure, unexpected response shape, etc.).
  unknown,
}

/// Thrown when creating a leave draft is rejected.
class LeaveDraftCreationException implements Exception {
  const LeaveDraftCreationException(this.reason, {this.message});
  final LeaveDraftCreationFailureReason reason;

  /// The server's own `message` for this error, when it sent one worth
  /// showing verbatim (currently just [overlappingRequest]) rather than a
  /// fixed client-side string.
  final String? message;
}
