import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/leave_type.dart';
import 'leave_request_service.dart';

final leaveDraftCreationControllerProvider =
    AsyncNotifierProvider.autoDispose<LeaveDraftCreationController, void>(
  LeaveDraftCreationController.new,
);

/// The result of [LeaveDraftCreationController.submit]'s two-step
/// create-then-submit flow.
class LeaveRequestSubmissionOutcome {
  const LeaveRequestSubmissionOutcome({
    required this.requestId,
    required this.submitted,
  });

  final String requestId;

  /// `true` once the request actually reached `Pending` (HR can see it).
  /// `false` when creation succeeded but the follow-up submit call failed,
  /// leaving the record behind as a Draft the employee must submit
  /// themselves from "My Leave Requests".
  final bool submitted;
}

/// Drives the "Request Leave" creation screen's submit action.
class LeaveDraftCreationController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Creates the leave request and immediately submits it.
  ///
  /// `POST /api/leave-requests` only ever produces a `Draft`, which the
  /// backend's HR-facing listing excludes — so a draft that is never
  /// submitted silently never reaches HR. Since the screen tells the
  /// employee their request was *sent*, both calls happen here, inside one
  /// guarded (and therefore one spinner's worth of) flow.
  ///
  /// Returns `null` when creation itself failed — the error is already in
  /// [state] for the screen's banner.
  Future<LeaveRequestSubmissionOutcome?> submit({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    state = const AsyncLoading();
    LeaveRequestSubmissionOutcome? outcome;
    state = await AsyncValue.guard(() async {
      final service = ref.read(leaveRequestServiceProvider);
      final created = await service.createLeaveDraft(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        attachment: attachment,
      );
      try {
        await service.submitLeaveDraft(created.requestId);
        outcome = LeaveRequestSubmissionOutcome(requestId: created.requestId, submitted: true);
      } catch (_) {
        // The draft exists but is still a Draft. Deliberately not rethrown:
        // the screen must not report a plain creation failure here, it has
        // to tell the employee the request was saved but not sent.
        outcome = LeaveRequestSubmissionOutcome(requestId: created.requestId, submitted: false);
      }
    });
    return outcome;
  }
}
