import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leave_api_client.dart';
import '../domain/leave_type.dart';
import 'leave_request_service.dart';

final leaveDraftCreationControllerProvider =
    AsyncNotifierProvider.autoDispose<LeaveDraftCreationController, void>(
  LeaveDraftCreationController.new,
);

/// Drives the "Request Leave" creation screen's submit action.
class LeaveDraftCreationController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<CreateLeaveDraftResult?> submit({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    File? attachment,
  }) async {
    state = const AsyncLoading();
    CreateLeaveDraftResult? result;
    state = await AsyncValue.guard(() async {
      result = await ref.read(leaveRequestServiceProvider).createLeaveDraft(
            leaveType: leaveType,
            startDate: startDate,
            endDate: endDate,
            reason: reason,
            attachment: attachment,
          );
    });
    return result;
  }
}
