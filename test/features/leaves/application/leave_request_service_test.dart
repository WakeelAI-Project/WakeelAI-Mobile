import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wakeel_ai_app/features/leaves/data/leave_api_client.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_request.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_request_exceptions.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_type.dart';
import 'package:wakeel_ai_app/features/leaves/application/leave_request_service.dart';

DioException _errorResponse(String errorCode, int statusCode, {String? message}) {
  final requestOptions = RequestOptions(path: '/api/leave-requests/req-1/submit');
  return DioException(
    requestOptions: requestOptions,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: {'error': errorCode, 'message': message},
    ),
  );
}

class _FakeLeaveApiClient implements LeaveApiClient {
  _FakeLeaveApiClient({
    this.submitError,
    this.cancelError,
    this.uploadError,
    this.uploadUrl,
    this.createError,
    this.createResult,
  });

  DioException? submitError;
  DioException? cancelError;
  DioException? uploadError;
  String? uploadUrl;
  DioException? createError;
  CreateLeaveDraftResult? createResult;

  String? submittedId;
  String? cancelledId;
  File? uploadedFile;
  LeaveType? createdLeaveType;
  File? createdAttachment;

  @override
  Future<LeaveRequestsPage> getLeaveRequests({String? status, int page = 1, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<LeaveRequest> getLeaveRequest(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> submitDraft(String id) async {
    submittedId = id;
    if (submitError != null) throw submitError!;
  }

  @override
  Future<void> cancelDraft(String id) async {
    cancelledId = id;
    if (cancelError != null) throw cancelError!;
  }

  @override
  Future<String> uploadAttachment(File file) async {
    uploadedFile = file;
    if (uploadError != null) throw uploadError!;
    return uploadUrl!;
  }

  @override
  Future<CreateLeaveDraftResult> createLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    createdLeaveType = leaveType;
    createdAttachment = attachment;
    if (createError != null) throw createError!;
    return createResult!;
  }
}

void main() {
  group('submitLeaveDraft', () {
    test('resolves on success', () async {
      final client = _FakeLeaveApiClient();
      final service = LeaveRequestService(client);

      await service.submitLeaveDraft('req-1');

      expect(client.submittedId, 'req-1');
    });

    test('throws LeaveDraftException(notFound) on 404 leave_request_not_found', () async {
      final client = _FakeLeaveApiClient(submitError: _errorResponse('leave_request_not_found', 404));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.submitLeaveDraft('req-1'),
        throwsA(isA<LeaveDraftException>().having((e) => e.reason, 'reason', LeaveDraftFailureReason.notFound)),
      );
    });

    test('throws LeaveDraftException(notADraft) on 409 not_a_draft', () async {
      final client = _FakeLeaveApiClient(submitError: _errorResponse('not_a_draft', 409));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.submitLeaveDraft('req-1'),
        throwsA(isA<LeaveDraftException>().having((e) => e.reason, 'reason', LeaveDraftFailureReason.notADraft)),
      );
    });

    test('throws LeaveDraftException(unknown) on an unrecognized error', () async {
      final client = _FakeLeaveApiClient(submitError: _errorResponse('server_error', 500));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.submitLeaveDraft('req-1'),
        throwsA(isA<LeaveDraftException>().having((e) => e.reason, 'reason', LeaveDraftFailureReason.unknown)),
      );
    });
  });

  group('deleteLeaveDraft', () {
    test('resolves on success', () async {
      final client = _FakeLeaveApiClient();
      final service = LeaveRequestService(client);

      await service.deleteLeaveDraft('req-1');

      expect(client.cancelledId, 'req-1');
    });

    test('throws LeaveDraftException(notADraft) on 409 not_a_draft', () async {
      final client = _FakeLeaveApiClient(cancelError: _errorResponse('not_a_draft', 409));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.deleteLeaveDraft('req-1'),
        throwsA(isA<LeaveDraftException>().having((e) => e.reason, 'reason', LeaveDraftFailureReason.notADraft)),
      );
    });
  });

  group('uploadLeaveAttachment', () {
    test('returns the url from the response, not the attachment_id', () async {
      final client = _FakeLeaveApiClient(uploadUrl: '/uploads/leave-requests/report.pdf');
      final service = LeaveRequestService(client);
      final file = File('report.pdf');

      final url = await service.uploadLeaveAttachment(file);

      expect(url, '/uploads/leave-requests/report.pdf');
      expect(client.uploadedFile, file);
    });

    test('throws LeaveAttachmentUploadException(invalidAttachment) on 400 invalid_attachment', () async {
      final client = _FakeLeaveApiClient(uploadError: _errorResponse('invalid_attachment', 400));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.uploadLeaveAttachment(File('report.pdf')),
        throwsA(isA<LeaveAttachmentUploadException>()
            .having((e) => e.reason, 'reason', LeaveAttachmentFailureReason.invalidAttachment)),
      );
    });

    test('throws LeaveAttachmentUploadException(missingFile) on 400 validation_error', () async {
      final client = _FakeLeaveApiClient(uploadError: _errorResponse('validation_error', 400));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.uploadLeaveAttachment(File('report.pdf')),
        throwsA(isA<LeaveAttachmentUploadException>()
            .having((e) => e.reason, 'reason', LeaveAttachmentFailureReason.missingFile)),
      );
    });
  });

  group('createLeaveDraft', () {
    test('resolves with the result on success', () async {
      final client = _FakeLeaveApiClient(
        createResult: const CreateLeaveDraftResult(requestId: 'req-9', status: 'Draft', daysRequested: 3),
      );
      final service = LeaveRequestService(client);

      final result = await service.createLeaveDraft(
        leaveType: LeaveType.annual,
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 3),
      );

      expect(result.requestId, 'req-9');
      expect(client.createdLeaveType, LeaveType.annual);
    });

    test('throws LeaveDraftCreationException(validationError) on 400 validation_error', () async {
      final client = _FakeLeaveApiClient(createError: _errorResponse('validation_error', 400));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.createLeaveDraft(
          leaveType: LeaveType.annual,
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 3),
        ),
        throwsA(isA<LeaveDraftCreationException>()
            .having((e) => e.reason, 'reason', LeaveDraftCreationFailureReason.validationError)),
      );
    });

    test('throws LeaveDraftCreationException(insufficientBalance) on 422 insufficient_leave_balance', () async {
      final client = _FakeLeaveApiClient(createError: _errorResponse('insufficient_leave_balance', 422));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.createLeaveDraft(
          leaveType: LeaveType.annual,
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 3),
        ),
        throwsA(isA<LeaveDraftCreationException>()
            .having((e) => e.reason, 'reason', LeaveDraftCreationFailureReason.insufficientBalance)),
      );
    });

    test('throws LeaveDraftCreationException(attachmentRequired) on 422 attachment_required', () async {
      final client = _FakeLeaveApiClient(createError: _errorResponse('attachment_required', 422));
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.createLeaveDraft(
          leaveType: LeaveType.sick,
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 3),
        ),
        throwsA(isA<LeaveDraftCreationException>()
            .having((e) => e.reason, 'reason', LeaveDraftCreationFailureReason.attachmentRequired)),
      );
    });

    test('throws LeaveDraftCreationException(overlappingRequest) with the server message on 409 overlapping_leave_request', () async {
      final client = _FakeLeaveApiClient(
        createError: _errorResponse(
          'overlapping_leave_request',
          409,
          message: 'You already have a pending Annual leave from 2026-03-01 to 2026-03-05 that overlaps these dates.',
        ),
      );
      final service = LeaveRequestService(client);

      await expectLater(
        () => service.createLeaveDraft(
          leaveType: LeaveType.annual,
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 3),
        ),
        throwsA(isA<LeaveDraftCreationException>()
            .having((e) => e.reason, 'reason', LeaveDraftCreationFailureReason.overlappingRequest)
            .having((e) => e.message, 'message',
                'You already have a pending Annual leave from 2026-03-01 to 2026-03-05 that overlaps these dates.')),
      );
    });
  });
}
